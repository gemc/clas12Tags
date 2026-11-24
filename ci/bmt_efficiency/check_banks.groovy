import org.jlab.jnp.hipo4.io.HipoReader
import org.jlab.jnp.hipo4.data.Bank
import org.jlab.jnp.hipo4.data.Event

File directory = new File(args[0])
def compare = { String left, String right, boolean unity, int expected ->
    def readers = [left, right].collect { label ->
        def r = new HipoReader()
        r.open(new File(directory, label + '.hipo').path)
        r
    }
    def counts = new int[6]
    int events = 0, adcRows = 0, fullRows = 0, keptRows = 0
    while (readers[0].hasNext()) {
        assert readers[1].hasNext()
        def banks = readers.collect { reader ->
            def event = new Event()
            reader.nextEvent(event)
            def read = { name ->
                def bank = new Bank(reader.schemaFactory.getSchema(name))
                event.read(bank)
                bank
            }
            [read('RUN::config'), read('BMT::adc'), read('MC::True')]
        }
        if (banks[0][0].rows == 0) { assert banks[1][0].rows == 0; continue }
        events++
        assert banks.every { it[0].getInt('run', 0) == (unity ? 18306 : 18305) }
        // Compare the complete serialized bank including row count, all columns and float bit patterns.
        for (int b : (unity ? [1, 2] : [1])) {
            def a = banks[0][b], c = banks[1][b]
            assert a.nodeBufferLength == c.nodeBufferLength
            assert a.byteBuffer.duplicate().position(0).limit(a.nodeBufferLength) ==
                   c.byteBuffer.duplicate().position(0).limit(c.nodeBufferLength)
        }
        def adc = banks[0][1]
        adcRows += adc.rows
        fullRows += banks[0][2].rows
        keptRows += banks[1][2].rows
        if (!unity) {
            // The fixed-angle geantino only crosses BMT. Every retained truth row must be populated.
            assert banks[1][2].rows == adc.rows
            assert banks[0][2].rows >= adc.rows
            for (def truth : [banks[0][2], banks[1][2]])
                for (int i=0; i<truth.rows; i++) assert truth.getByte('detector', i) == 1
            def layers = [] as Set
            for (int i=0; i<adc.rows; i++) {
                assert adc.getByte('sector', i) == 2
                assert adc.getByte('layer', i) != 2
                if (adc.getInt('ADC', i)>0 && adc.getShort('component', i)>0) layers << adc.getByte('layer', i).intValue()
            }
            layers.each { counts[it-1]++ }
        }
    }
    assert !readers[1].hasNext() && events == expected && adcRows > 0 && fullRows > 0
    readers.each { it.close() }
    if (!unity) {
        assert fullRows > keptRows
        [1.0, 0.0, 0.5, 0.9, 0.25, 0.75].eachWithIndex { p,l ->
            assert Math.abs(counts[l]-events*p) <= 4*Math.sqrt(events*p*(1-p))
        }
        println("Sector 2 events with a strip signal: ${counts.toList()} / $events")
    }
    println("$left vs $right: $events events, $adcRows identical ADC rows, truth rows $fullRows / $keptRows")
}
compare('unity-on', 'unity-off', true, 300)
compare('full-truth', 'kept-truth', false, 1200)

def reader = new HipoReader()
reader.open(new File(directory, 'switch.hipo').path)
def header = new Bank(reader.schemaFactory.getSchema('RUN::config'))
def adc = new Bank(reader.schemaFactory.getSchema('BMT::adc'))
def event = new Event()
def totals = [18305: 0, 18306: 0]
while (reader.hasNext()) {
    reader.nextEvent(event)
    event.read(header)
    if (!header.rows) continue
    int run = header.getInt('run', 0)
    assert totals.containsKey(run)
    totals[run]++
    event.read(adc)
    // Sector 2, layer 2 changes from dead to fully efficient across the run boundary.
    boolean layerTwoSignal = (0..<adc.rows).any { i ->
        adc.getByte('sector', i) == 2 && adc.getByte('layer', i) == 2 && adc.getInt('ADC', i) > 0
    }
    assert layerTwoSignal == (run == 18306)
}
reader.close()
assert totals.values().sum() == 120 && totals.values().min() > 0
println("Weighted events with verified tile response by run: $totals")

// Fixed-angle probes cross every layer of the selected sector once per event.
def checkLayers = { String label, int run, int n, int sector, Set expected, boolean expectEmptyBank ->
    def input = new HipoReader()
    input.open(new File(directory, label + '.hipo').path)
    def config = new Bank(input.schemaFactory.getSchema('RUN::config'))
    def signals = new Bank(input.schemaFactory.getSchema('BMT::adc'))
    int events = 0, positiveRows = 0
    while (input.hasNext()) {
        input.nextEvent(event)
        event.read(config)
        if (!config.rows) continue
        assert config.getInt('run', 0) == run
        events++
        event.read(signals)
        if (expectEmptyBank) assert signals.rows == 0
        def layers = [] as Set
        for (int i=0; i<signals.rows; i++) {
            // Legacy digitization can write placeholder rows for a dead tile.
            if (signals.getShort('component', i) <= 0 || signals.getInt('ADC', i) <= 0) {
                assert expected.empty
                continue
            }
            assert signals.getByte('sector', i) == sector
            layers << signals.getByte('layer', i).intValue()
            positiveRows++
        }
        assert layers == expected
    }
    input.close()
    assert events == n
    println("$label: run $run, $events events, $positiveRows positive strip ADC rows, layers $expected")
}
checkLayers('fallback', 18307, 12, 1, [1, 2, 3, 4, 6] as Set, false)
checkLayers('legacy-strip-off', 10000, 24, 2, (1..6) as Set, false)
checkLayers('measured-strip-off', 10000, 24, 2, [] as Set, true)
checkLayers('legacy-no-drift', 18307, 6, 2, [] as Set, false)
