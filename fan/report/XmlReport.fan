using xml

** Report the test results as Xml.
class XmlReport : TestReport {	

	** Test results to output
	XTestResult[] 	results
	Bool 			removeProps
	
	** Constructor
	new make(XTestResult[] results := [,], Bool removeProps := false) {
		this.results 		= results
		this.removeProps 	= removeProps
	}
	
	** Write an Xml document to 'out' stream.
	override Void write(OutStream out, Bool close := true) {
		try {
			doc	 := XDoc { XElem("testsuites"), }
			results.each |XTestResult result| { doc.root.add(result.toXml(removeProps)) }
			
			doc.write(out)
		}
		finally {
			if (close)
				out.close			
		}
		
	}
	
	Int numFailures() {
		countNumOf(TestFailure#) {
			it.failures
		}
	}
	
	Int numErrors() {
		countNumOf(TestError#) {
			it.errors
		}
	}
	
	Int numSkipped() {
		countNumOf(TestSkipped#) {
			it.skipped
		}
	}
	
	Int numPassed() {
		countNumOf(TestSuccess#) {
			it.successes
		}
	}
	
	private Int countNumOf(Type type, |TestSummary->Int| fn) {	
		count := 0
		results.each |XTestResult result| { 
			if (result.typeof == TestSummary#)
				count += fn(result)
			else if (result.typeof == type)
				count += 1
		}

		return count
	}
	
}
