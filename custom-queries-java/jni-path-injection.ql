/**
 * @name Cross-Language JNI Path Injection
 * @description Tracks untrusted user input passing into a native method that could lead to file system manipulation.
 * @kind path-problem
 * @problem.severity error
 * @security-tip Tracing tainted input across JNI requires verification of safe parameter handling in native extensions.
 * @id java/jni-path-injection
 * @tags security
 * external/cwe/cwe-22
 */

import java
import semmle.code.java.dataflow.TaintTracking
import MyFlow::PathGraph

module JniFlowConfig implements DataFlow::ConfigSig {

  // Step 1: Define what CodeQL treats as the starting point (Tainted Source)
  predicate isSource(DataFlow::Node source) {
    exists(RemoteFlowSource rfs | source = rfs)
  }

  // Step 2: Define what CodeQL treats as the end point (Sink)
  // We look for arguments being passed into any method flagged with the 'native' modifier.
  predicate isSink(DataFlow::Node sink) {
    exists(MethodCall mc |
      mc.getMethod().isNative() and
      sink.asExpr() = mc.getAnArgument()
    )
  }
}

// Instantiate our custom tracking engine
module MyFlow = TaintTracking::Global<JniFlowConfig>;

from MyFlow::PathNode source, MyFlow::PathNode sink
where MyFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Tainted user input flows cross-boundary into native method invocation."
