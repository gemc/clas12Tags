#!/usr/bin/env bash

# Run a temporary Java agent inside Maven's JVM; no Maven plugins or network access are needed.
set -euo pipefail
: "${JAVA_HOME:?JAVA_HOME must point to the selected JDK}"

report_dir=$(mktemp -d)
trap 'rm -rf "$report_dir"' EXIT
cat > "$report_dir/MavenTrustReport.java" <<'JAVA'
import java.nio.file.*;
import java.security.*;
import java.security.cert.X509Certificate;
import javax.net.ssl.*;

public class MavenTrustReport {
    private static void report(String key, Object value) {
        System.out.println("MAVEN_TRUST " + key + "=" + value);
    }

    private static String sha256(byte[] bytes) throws Exception {
        StringBuilder result = new StringBuilder();
        for (byte b : MessageDigest.getInstance("SHA-256").digest(bytes)) {
            result.append(String.format("%02X", b & 255));
        }
        return result.toString();
    }

    public static void premain(String ignored) {
        for (String key : new String[] {"java.version", "java.vendor", "java.home",
                "javax.net.ssl.trustStore", "javax.net.ssl.trustStoreType"}) {
            report(key, System.getProperty(key, "<default>"));
        }
        try {
            String explicit = System.getProperty("javax.net.ssl.trustStore");
            Path store;
            if (explicit == null) {
                store = Paths.get(System.getProperty("java.home"), "lib", "security", "jssecacerts");
                if (!Files.exists(store)) {
                    store = store.resolveSibling("cacerts");
                }
            } else {
                store = Paths.get(explicit);
            }
            if (Files.isRegularFile(store)) {
                report("trustStore.realPath", store.toRealPath());
                report("trustStore.sha256", sha256(Files.readAllBytes(store)));
            } else {
                report("trustStore.file", "unavailable: " + store);
            }
            report("keyStore.defaultType", KeyStore.getDefaultType());
            TrustManagerFactory factory = TrustManagerFactory.getInstance(
                    TrustManagerFactory.getDefaultAlgorithm());
            factory.init((KeyStore) null);
            for (TrustManager manager : factory.getTrustManagers()) {
                if (!(manager instanceof X509TrustManager)) {
                    continue;
                }
                X509Certificate[] issuers = ((X509TrustManager) manager).getAcceptedIssuers();
                report("trustedIssuers", issuers.length);
                boolean emsign = false;
                for (X509Certificate cert : issuers) {
                    String fingerprint = sha256(cert.getEncoded());
                    if (fingerprint.equals(
                            "40F6AF0346A99AA1CD1D555A4E9CCE62C7F9634603EE406615833DC8C8D00367")) {
                        emsign = true;
                        report("emsignRootG1.subject", cert.getSubjectX500Principal());
                        report("emsignRootG1.sha256", fingerprint);
                    }
                }
                report("emsignRootG1.trusted", emsign);
            }
        } catch (Exception error) {
            report("error", error.getClass().getName());
        }
    }
}
JAVA

# Java 8 bytecode lets the report expose an unexpectedly older Maven JVM too.
env -u JAVA_TOOL_OPTIONS -u JDK_JAVA_OPTIONS -u _JAVA_OPTIONS \
    "$JAVA_HOME/bin/javac" --release 8 -Xlint:-options -d "$report_dir" "$report_dir/MavenTrustReport.java"
printf 'Premain-Class: MavenTrustReport\n' > "$report_dir/manifest"
env -u JAVA_TOOL_OPTIONS -u JDK_JAVA_OPTIONS -u _JAVA_OPTIONS \
    "$JAVA_HOME/bin/jar" cfm "$report_dir/report.jar" "$report_dir/manifest" -C "$report_dir" \
    MavenTrustReport.class

printf 'MAVEN_TRUST selected.java.home=%s\n' "$JAVA_HOME"
printf 'MAVEN_TRUST launcher=%s\n' "$(command -v mvn)"
printf 'MAVEN_TRUST original.launcher=%s\n' "${COATJAVA_MAVEN_EXECUTABLE:-<not wrapped>}"
if [[ $# -gt 0 ]]; then
    cd -- "$1"
fi
status=0
MAVEN_OPTS="${MAVEN_OPTS:-} -javaagent:$report_dir/report.jar" \
    mvn --batch-mode --version > "$report_dir/output" 2>&1 || status=$?
# Print only the report and Maven's public version banner, avoiding raw JVM option/environment dumps.
awk '{
    gsub(/\033\[[0-9;]*m/, "")
    if ($0 ~ /^(MAVEN_TRUST |Apache Maven |Maven home:|Java version:|Default locale:|OS name:)/) print
}' "$report_dir/output"
if ! grep -q '^MAVEN_TRUST java.home=' "$report_dir/output"; then
    echo "Maven did not load the diagnostic agent; its launcher may override MAVEN_OPTS." >&2
    exit 1
fi
exit "$status"
