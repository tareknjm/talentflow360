Map<String, Object> inputs = new Map<String, Object>{
    'candidateCode' => 'TF-PROBE-001'
};

Flow.Interview.TF_ConnectionProbe probe = new Flow.Interview.TF_ConnectionProbe(inputs);
probe.start();

System.debug('TF_CONNECTION_PROBE_OUTPUT=' + probe.getVariableValue('safeSummary'));
