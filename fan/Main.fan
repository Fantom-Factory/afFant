using util

** Main execution point of Xfant pod.
class Main : AbstractMain {
	@Arg { help = "<pod> [pod]* | <pod>::<test> | <pod>::<test>.<method>" }
	Str[] targets := [,]
	
	@Opt { help = "test all pods" }
	Bool all
	
	@Opt { help = "remove properties from xml"; aliases=["n"] }
	Bool noProps
				
	@Opt { help = "output file"; aliases=["o"] } 
	File? output
	
	@Opt { help = "disable debug output"; aliases=["nl"] }
	Bool noDebugLog
	
	override Int run() {
		Xfant? xfant
		 
		// Add tests to execute
		xfant = Xfant {}
		xfant.addAll(all ? Pod.list : targets)

		log.level = (noDebugLog) ? LogLevel.info : LogLevel.debug
		
		// if no tests were given, show usage
		if (!xfant.hasTests) {
			echo("Could not find tests in: " + targets.join(" ") + "\n")
			return usage
		}
		
		// Run tests
		try {
			startTime := Duration.now
			xfant.run
			timeElapsed := ((Duration.now - startTime).toMillis).toStr + "ms"
			log.debug("")
			log.debug("Time: $timeElapsed")

			numTests := xfant.results.size
			numMethods := 0
			numVerifies := 0
			numFailures := 0
			
			xfant.results.each |TestSummary summary| {
				numMethods = numMethods + summary.results.size
				summary.results.each |TestResult result| {
					numVerifies += result.numVerifies
					if (result.typeof == TestFailure#) {
						if (numFailures == 0) {
							log.debug("")
							log.debug("Failed:")
						}
						
						log.debug(" " + result.test.classname + "." + result.test.name)
						numFailures++
					}
				}
			}
			
			log.debug("")
			log.debug("***")
			endingText := (numFailures == 0) ? "All tests passed!" : "$numFailures FAILURES"
			log.debug("*** $endingText [$numTests tests, $numMethods methods, $numVerifies verifies]")
			log.debug("***")
			
			report :=(XmlReport) xfant.report(noProps)
			report.write(output?.out ?: Env.cur.out, output != null) // If an output file is not specified, print to Env.cur
			
			if (report.numErrors > 0)
				return -20
			if (report.numFailures > 0)
				return -10
			
			return 0
		}
		catch (Err err) {
			log.err("Unexpected error running tests", err)
			return -1
		}
	}
}