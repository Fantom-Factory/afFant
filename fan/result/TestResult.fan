using xml

** Result of a test case.
const class TestResult : XTestResult {	

	** See 'XTestResult.test'
	override const Xtest test
	
	** The time taken for a text to execute
	override const Duration elapsed
	
	** The number of verifies present in the test
	const Int? numVerifies
	
	** Constructor
	new make(Xtest test, Duration started, Int numVerifies) { 
		this.test			= test
		this.elapsed		= Duration.now - started
		this.numVerifies 	= numVerifies
	}

	override XElem toXml(Bool removeProps := false) {
		XElem("testcase") {
			XAttr("name", test.name),
			XAttr("classname", test.classname),
			XAttr("time", (elapsed.toMillis / 1000.0f).toStr),
		}
	}
}

const class TestSuccess : TestResult {
	
	new make(Xtest test, Duration started, Int numVerifies) 
		: super(test, started, numVerifies) {}
}

const class TestSkipped : TestResult {
	new make(Xtest test, Duration started, Int numVerifies := 0) 
		: super(test, started, numVerifies) {}
	
	override XElem toXml(Bool removeProps := false) {
		super.toXml(removeProps).add(XElem("skipped"))
	}
}

	
const class TestIssue : TestResult {
	** Error produced during execution
	const Err? err
		
	new make(Xtest test, Duration started, Int numVerifies, Err err) 
		: super(test, started, numVerifies) {
		this.err = err
	}
	
	XElem issue(Str name) {
		XElem(name) {
			XAttr("message", err.msg),
			XAttr("type", err.typeof.name),
			XText(err.traceToStr),
		}	
	}
}

const class TestError : TestIssue { 
	new make(Xtest test, Duration started, Int numVerifies, Err err) 
		: super(test, started, numVerifies, err) {}
	
	override XElem toXml(Bool removeProps := false) {
		super.toXml(removeProps).add(issue("error"))
	}
}

const class TestFailure : TestIssue { 
	new make(Xtest test, Duration started, Int numVerifies, Err err) 
		: super(test, started, numVerifies, err) {}
	
	override XElem toXml(Bool removeProps := false) {
		super.toXml(removeProps).add(issue("failure"))
	}
}	
