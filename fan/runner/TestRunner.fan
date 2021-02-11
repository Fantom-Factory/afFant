
** Execute the tests and returns the results.
class TestRunner { 

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
		if (test.isIgnored) {
			return TestSkipped(test, Duration.now)
		}
		
		Test? target
		Duration? startTime
				 
		try {
			target = test.makeTest				
			target.setup
			startTime = Duration.now
			test.call(target)
			return TestSuccess(test, startTime)
		}
		catch (TestErr err) {
			return TestFailure(test, startTime, err)
		}
		catch (Err err) {
			return TestError(test, startTime, err)
		}
		finally {
			target?.teardown
		}
	}
	
	** Run all the tests in the suite, and returns the result
	** as summary.
	protected TestSummary runTestSuite(TestSuite suite) {
		tests := (suite.isIgnored) ? 
			[TestSkipped(suite, Duration.now)] :
			suite.tests.map |Xtest test->XTestResult| { 
				return run(test) 
			}
		
			
		summary := TestSummary {
			it.test		= suite
			it.results  = tests
		}
		return summary
	} 
}
