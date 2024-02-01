
** Execute the tests and returns the results.
class TestRunner { 
	
	private const Log log := this.typeof.pod.log
	
	** Execute a test and return the results
	XTestResult run(Xtest test) {	
		switch (test.typeof) {
			case TestCase#:
				log.debug("Running test: " + test.name)
				return runTestCase(test)
			case TestSuite#:
				log.debug("Running test suite: " + test.name)
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
		startTime := Duration.now
				 
		try {
			target = test.makeTest
			
			try target->curTestMethod = test.method
			catch { /* meh - curTestMethod only appeared in Fantom 1.0.80 */ }

			target.setup
			test.call(target)
			log.debug("Test successful")
			return TestSuccess(test, startTime)
		}
		catch (TestErr err) {
			log.debug("Test failed")
			return TestFailure(test, startTime, err)
		}
		catch (Err err) {
			log.debug("Test errored")
			return TestError(test, startTime, err)
		}
		finally {
			// TODO catch errors and report them
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
