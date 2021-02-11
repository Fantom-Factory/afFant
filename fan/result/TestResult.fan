using xml

** Result of a test case.
const class TestResult : XTestResult {	

	** See 'XTestResult.test'
	override const Xtest test
	
	override const Duration elapsed

	** Constructor
	new make(Xtest test, Duration started) { 
		this.test		= test
		this.elapsed	= Duration.now - started
	}

	override XElem toXml() {
		XElem("testcase") {
			XAttr("name", test.name),
			XAttr("classname", test.classname),
			XAttr("time", (elapsed.toMillis / 1000.0f).toStr),
		}
	}
}

const class TestSuccess: TestResult {
	new make(Xtest test, Duration started) 
		: super(test, started) {}
}

const class TestSkipped : TestResult {
	new make(Xtest test, Duration started) 
		: super(test, started) {}
	
	override XElem toXml() {
		super.toXml.add(XElem("skipped"))
	}
}

	
const class TestIssue : TestResult {

	** Error produced during execution
	const Err? err
		
	new make(Xtest test, Duration started, Err err) 
		: super(test, started) {
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
	new make(Xtest test, Duration started, Err err) 
		: super(test, started, err) {}
	
	override XElem toXml() {
		super.toXml.add(issue("error"))
	}
}

const class TestFailure : TestIssue { 
	new make(Xtest test, Duration started, Err err) 
		: super(test, started, err) {}
	
	override XElem toXml() {
		super.toXml.add(issue("failure"))
	}
}	
