** Creates a group of test from a 'Test#' subclass.
**
** The type must be a 'Test#' subclass.
**	- Cannot be abstract.
**	- Each method that starts with "test" that not is abstract is added
**		to list variable 'tests'.
**
** If the type has a facet '@Ignore' the test cases are not created and
** 'tests' variable is an empty list. 
**
** See 'TestCase'.
const class TestSuite : Xtest {

	** Creates a test for a pod.
	** Take all classes in the pod that are subclasses of 'Test#',
	** non abstract and creates a testcase for each of them.
	static TestSuite[] fromPod(Pod pod) { 
		types := pod.types.findAll |type->Bool| {
			type.fits(Test#) && !type.isAbstract
		}
		
		return types.map { fromType(it) }.exclude { it == null }
	}
	
	** Match 'pattern' with 'pod::type' and returns a 'TestSuite' 
	** with all the test cases extracted from the type.
	** if 'pattern' does not match and checked is 'true' throws an
	** 'ArgErr' error, else returns null.
	static new fromStr(Str pattern, Bool checked := true) {
		try {
			matcher := re.matcher(pattern)
			
			if (!matcher.matches)
				throw ArgErr("Expected 'pod::type' but got: '${pattern}'")
			
			pod	:= Pod.find(matcher.group(1))
			type := pod.type(matcher.group(2))
			
			return fromType(type)
		}
		catch (Err e) {
			if (checked) {
				throw ArgErr("Wrong test type ${pattern}", e)
			}
			else {
				return null
			}
		}
	}
	
	** Find all methods in a type that starts with 'test' and are
	** non abstract
	static Slot[] findTestMethods(Type type) {
		type.methods.findAll |method->Bool| { 
			method.name.startsWith("test") && !method.isAbstract			
		}
	}
	
	** Constructor from 'type' adding all the test methods. 
	** See 'TestCase'
	static new fromType(Type type) {
		if (!type.fits(Test#)) {
			throw ArgErr("Test type must be 'Test#' subclass")
		}
		
		if (type.isAbstract) {
			throw ArgErr("Test type mustn't be abstract")
		}

		testMethods := findTestMethods(type)
		if (testMethods.isEmpty)
			return null
		
		return TestSuite() {
			it.type	= type
			it.tests = isIgnored ? Xtest#.emptyList : testMethods.map { TestCase(it) }
		}
	}
	
	** It block ctor.
	new make(|This| f) { f(this) }

	Bool isIgnored() {
		type.hasFacet(Ignore#)
	} 
		
	** The name of this test is the type's classname.
	override Str name() {
		type.name
	}
	
	** Qualified classname to wich this tests belongs.
	override Str classname() {
		type.qname
	}
	
	** Package/pod name
	override Str pod() {
		type.pod.name
	}	
	
	** Type with the tests
	const Type type
	
	** Group of tests to execute.
	const Xtest[] tests
	
	** Regex to parse a pod::type 'Str' test 
	private const static Regex re := "(\\w+)[:]{2}(\\w+)".toRegex
}
