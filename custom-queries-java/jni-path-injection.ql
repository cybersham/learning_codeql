/**
 * @name Untrusted data flowing to native boundary
 * @description Traces tainted input passed to a Java native method.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @id java/untrusted-data-to-jni
 * @tags security
 */

import java
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

module JniFlowConfig implements DataFlow::ConfigSig {
  
  // 1. Where the untrusted data enters
  predicate isSource(DataFlow::Node source) {
    exists(RemoteFlowSource rfs | source = rfs)
  }

  // 2. Where the data should never go unvalidated
  predicate isSink(DataFlow::Node sink) {
    exists(MethodAccess ma |
      ma.getMethod().isNative() and
      sink.asExpr() = ma.getAnArgument()
    )
  }
}

module JniFlow = TaintTracking::Global<JniFlowConfig>;

from JniFlow::PathNode source, JniFlow::PathNode sink
where JniFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Alert: Untrusted data flows directly into native method " + sink.getNode().getEnclosingCallable().getName() + " without validation."