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
// This import allows CodeQL to show the visual step-by-step path line in GitHub UI
import DataFlow::PathGraph

class JniConfiguration extends TaintTracking::Configuration {
  JniConfiguration() { this = "JniConfiguration" }

  // 1. Where the "dirty" data enters our system
  override predicate isSource(DataFlow::Node source) {
    // remoteFlowSource includes standard inputs like our Scanner implementation
    exists(RemoteFlowSource rfs | source = rfs)
  }

  // 2. Where the data should never go unvalidated
  override predicate isSink(DataFlow::Node sink) {
    // Look through all method calls (ma) in the program
    exists(MethodAccess ma |
      // If the target method is declared with the 'native' keyword
      ma.getMethod().isNative() and
      // And the sink is one of the arguments passed to that method
      sink.asExpr() = ma.getAnArgument()
    )
  }
}

// The query structurally expects a source, a sink, and the path linking them
from JniConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Alert: Untrusted data flows directly into native method " + sink.getNode().(Expr).getEnclosingCallable().getName() + " without validation."