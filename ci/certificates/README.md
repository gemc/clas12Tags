# Maven repository certificate trust

`emsign-root-ca-g1.pem` is the public emSign Root CA - G1 certificate, extracted from the trusted OS
CA bundle at `/etc/ssl/cert.pem`. It validates the InCommon chain presented by `code.jlab.org` on
November 9, 2026. This chain uses a different root from the image's private JLab CA.

SHA-256 fingerprint:

```text
40:F6:AF:03:46:A9:9A:A1:CD:1D:55:5A:4E:9C:CE:62:C7:F9:63:46:03:EE:40:66:15:83:3D:C8:C8:D0:03:67
```

The root is valid from February 18, 2018 through February 18, 2043. The CI trust helper adds it to the
selected JDK alongside the image's JLab CA. Certificate and hostname verification remain enabled.
