using xml

** Report the test results as Xml.
class XmlReport : TestReport {	

	** Test results to output
	XTestResult[] results
	
	** Constructor
	new make(XTestResult[] results := [,]) {
		this.results = results
	}
	
	** Write an Xml document to 'out' stream.
	override Void write(OutStream out, Bool close := true) {
		try {
			doc	 := XDoc { XElem("testsuites"), }
			results.each |XTestResult result| { doc.root.add(result.toXml) }
			
			doc.write(out)
		}
		finally {
			if (close)
				out.close			
		}
		
	}
	
	Int numFailures() {
		if (results.isEmpty)
			throw Err("Can't find any results")
		
		summaries := results.findAll |XTestResult result->Bool| { result.typeof == TestSummary# }
		if (summaries.isEmpty)
			return results.findAll { it.typeof == TestFailure# }.size
		
		failures := 0
		summaries.each |TestSummary summary| { 
			failures += summary.failures
		}
		return failures
	}
	
	Int numErrors() {
		if (results.isEmpty)
			throw Err("Can't find any results")
		
		summaries := results.findAll |XTestResult result->Bool| { result.typeof == TestSummary# }
		if (summaries.isEmpty)
			return results.findAll { it.typeof == TestError# }.size
		
		errors := 0
		summaries.each |TestSummary summary| { 
			errors += summary.errors
		}
		return errors
	}
	
	Int numSkipped() {
		if (results.isEmpty)
			throw Err("Can't find any results")
		
		summaries := results.findAll |XTestResult result->Bool| { result.typeof == TestSummary# }
		if (summaries.isEmpty)
			return results.findAll { it.typeof == TestSkipped# }.size
		
		skipped := 0
		summaries.each |TestSummary summary| { 
			skipped += summary.skipped
		}
		return skipped
	}
	
	Int numPassed() {
		if (results.isEmpty)
			throw Err("Can't find any results")
		
		summaries := results.findAll |XTestResult result->Bool| { result.typeof == TestSummary# }
		if (summaries.isEmpty)
			return results.findAll { it.typeof == TestSuccess# }.size
		
		passed := 0
		summaries.each |TestSummary summary| { 
			passed += summary.successes
		}
		return passed
	}
	
}
