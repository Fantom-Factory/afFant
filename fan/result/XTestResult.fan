using xml

** Result of a a finished test. 
mixin XTestResult {

	** Test executed
	abstract Xtest test()
		
	** Time elapsed in the execution of the test.
	abstract Duration elapsed()
	
	** Result of the test in Xml
	abstract XElem toXml(Bool removeProps := false)
}
