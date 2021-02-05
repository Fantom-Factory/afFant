using util

** Main execution point of Xfant pod.
class Main : AbstractMain {
	@Arg { help = "<pod> [pod]* | <pod>::<test> | <pod>::<test>.<method>" }
	Str[] targets := [,]
	
	@Opt { help = "test all pods" }
	Bool all
				
	@Opt { help = "output file"; aliases=["o"] } 
	File? output
	
	override Int run() {		
		Xfant? xfant
		
		// Add tests to execute
		xfant = Xfant {}
		xfant.addAll(all ? Pod.list : targets)

		
		// if no tests were given, show usage
		if (!xfant.hasTests) {
			echo("Could not find tests in: " + targets.join(" ") + "\n")
			return usage
		}
		 
		// Run tests
		try {
			xfant.run
			report :=(XmlReport) xfant.report()
			report.write(output?.out ?: Env.cur.out, output != null) // If an output file is not specified, print to Env.cur
			
			if (report.numFailures > 0)
				return -10
			if (report.numErrors > 0)
				return -20
			
			return 0
		}
		catch (Err err) {
			log.err("Unexpected error running tests", err)
			return -1
		}
	}
}