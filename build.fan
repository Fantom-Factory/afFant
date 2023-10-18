using build

class Build : BuildPod {
	new make() {
		podName = "afFant"
		summary = "Fant like tool that shows test results in JUnit Xml"
		version = Version("0.1.0")
		
		meta = [
			"stripTest" : "true",
			"pod.dis"	: "afFant"
		]
		
		depends = [
			"sys 1.0+",
			"util 1.0+",
			"xml 1.0+"
		]
		
		srcDirs = [
			`fan/`,
			`fan/case/`,
			`fan/result/`,
			`fan/report/`,
			`fan/runner/`,
			`test/`
		]
		
		resDirs = [
			`doc/`
		]
	}
}
