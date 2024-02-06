
** Execute the tests and returns the results.
class TestRunner { 
	
	private const Log log := this.typeof.pod.log
	
	** Execute a test and return the results
	XTestResult run(Xtest test) {	
		switch (test.typeof) {
			case TestCase#:
				return runTestCase(test)
			case TestSuite#:
				return runTestSuite(test)
			default:
				throw ArgErr("Unknown test type: ${test}")
		}
	}
	
	** Run a 'TestCase' and returns a result.
	protected XTestResult runTestCase(TestCase test) {
		if (test.isIgnored) 
			return TestSkipped(test, Duration.now)
		
		Test? target
		TestResult? result
		startTime := Duration.now
				 
		try {
			log.debug("-- Run:  $test.classname" + "." + "$test.name")
			
			target = test.makeTest
			
			try target->curTestMethod = test.method
			catch { /* meh - curTestMethod only appeared in Fantom 1.0.80 */ }

			target.setup
			test.call(target)
			result =  TestSuccess(test, startTime, target->verifyCount)
		}
		catch (TestErr err) {
			result =  TestFailure(test, startTime, target->verifyCount, err)
		}
		catch (Err err) {
			result = TestError(test, startTime, target->verifyCount, err)
		}
		finally {
			target?.teardown
			result.printResult
		}
		
		return result
	}
	
	** Run all the tests in the suite, and returns the result
	** as summary.
	protected TestSummary runTestSuite(TestSuite suite) {
		tests := (suite.isIgnored) 
			? [TestSkipped(suite, Duration.now)]
			: suite.tests.map |Xtest test->XTestResult| { run(test) }
			
		summary := TestSummary {
			it.test		= suite
			it.results  = tests
		}
		return summary
	} 
}
