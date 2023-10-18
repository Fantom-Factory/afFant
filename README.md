# afFant v0.1.0
---

[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](https://fantom-lang.org/)
[![pod: v0.1.0](http://img.shields.io/badge/pod-v0.1.0-yellow.svg)](http://eggbox.fantomfactory.org/pods/afFant)
[![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)](https://choosealicense.com/licenses/isc/)

## Overview

Xfant is a `fant` like tool that outputs tests results in format compatible with JUnit's XML. This XML output can be used with java tools like *Jenkins CI*.

## <a name="Install"></a>Install

Install `afFant` with the Fantom Pod Manager ( [FPM](http://eggbox.fantomfactory.org/pods/afFpm) ):

    C:\> fpm install afFant

Or install `afFant` with [fanr](https://fantom.org/doc/docFanr/Tool.html#install):

    C:\> fanr install -r http://eggbox.fantomfactory.org/fanr/ afFant

To use in a [Fantom](https://fantom-lang.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFant 0.1"]

## <a name="documentation"></a>Documentation

Full API & fandocs are available on the [Eggbox](http://eggbox.fantomfactory.org/pods/afFant/) - the Fantom Pod Repository.

## Usage

`fan xfant [options] <targets>*`

### Options

* `-all`, test all pods installed in the system. This option ignores the rest of arguments passed.


### Arguments

`fan xfant target .. target`, where `target` is:

* A pod name,
* A type qualified name,
* A method qualified name


Example:

* `fan xfant xml`
* `fan xfant xml::PullTest`
* `fan xfant xml::PullTest.testPi`
* `fan xfant xml inet xfant::ExampleTest`


### Type of tests

There are three type of tests:

* test a pod
* test a subclass of `Test#`
* test a method of a subclass of `Test#`


#### Testing a pod

When a pod is selected, all subclasses of `Test#` that are non abstract are tested.

From command line:

    fan xfant xml

will test the `xml` pod. The pod `xml` has `DomTest`, `ParserErrTest`, `ParserTest`, `PullTest` and `WriteTest` testcases.

#### Testing a'Test#' subtype

For each `Test#` subclass all methods whose name starts with `test` not abstract are tested.

From command line:

    fan xfant xml::PullTest

will add `testElems`, `testAttrs`, `testMixed`, `testPi`, `testDoc`, `testNs` and `testSkipAndNem` to the tests.

#### Testing a method

A method `testPi` is added to test from command line:

    fan xfant xml::PullTest.testPi

### Test results

Once a test is executed the `TestResult` can be a success, a failure, an error or a test skipped.

#### Success

A test that finished as expected is a success.

#### Failure

A test that fails the `verify` methods is a failure. The `TestErr` raised is saved as information of the failure. The stack trace is shown in the XML.

#### Error

Executing the test something was wrong. An `Err` raised, an unexpected error happened. This `Err` information is saved and showed in the report with the stack trace.

#### Skipped

There are times when you don't want that a test is executed. The facet `Ignore` is used for this purpose. If `Ignore` is used with a `Test#` subclass, all the tests are skipped. If `Ignore` is used before a method, only this method is skipped.

All tests are ignored:

    @Ignore
    class ExampleTest : Test
    {
      Void testOne()
      {
        verifyEq(1,1)
      }
    }

Only one method is ignored:

    class ExampleTest : Test
    {
      @Ignore    
      Void testOne()
      {
        verifyEq(1,1)
      }
    }

### Usage with Jenkins

In order to create a *Fantom* project with `xfant` follow the next steps.

1. Install the `xfant` pod.
2. Create a `Freestyle project` in Jenkins.
3. Add a `build` step `execute shell` with this code:    export FAN_ENV=util::PathEnv
    export FAN_ENV_PATH=$WORKSPACE
    fan build.fan


    to compile the pod.

4. Add another `build` step `execute shell` with this code:    export FAN_ENV=util::PathEnv
    export FAN_ENV_PATH=$WORKSPACE
    fan xfant your_pod_name > your_pod_name.xml


    to execute the tests and write the report in a file.

5. Add a `Post-build` action named `Publish JUnit test result report`. In **test report XMLs** use `*.xml`


### Tests of Xfant

Some of tests included within `xfant` pod will fail when are executed with `fant`. That's ok, because `xfant` needs failures to create all types of xml output.

### JUnit's XML standard and Xfant XML

The tests' xml output is compatible with [https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd](https://github.com/windyroad/JUnit-Schema/blob/master/JUnit.xsd) but diverges in three points.

#### System properties

An example of JUnit's schema is:

    <testsuites>
      <testsuite name='ExampleTest' classname='xfant::ExampleTest' time='0' tests='3' errors='1' failures='1' skipped='1' timestamp='2017-05-28T13:30:22.108+02:00'>
        <properties>
          <property name='java.version' value='9-internal'/>
          <property name='java.vm.name' value='OpenJDK 64-Bit Server VM'/>
        </properties>
        <testcase name='testShouldPass' classname='xfant::ExampleTest' time='0'/>
        <testcase name='testShouldFail' classname='xfant::ExampleTest' time='0'>
          <failure message='Test failed: This test should be a failure' type='TestErr'>
            sys::TestErr: Test failed: This test should be a failure
            fan.sys.Test.err (Test.java:239)
            fan.sys.Test.fail (Test.java:231)
            ...
          </failure>
        </testcase>
        <testcase name='testShouldErr' classname='xfant::ExampleTest' time='0'>
          <error message='This test should be an error' type='Err'>
             sys::Err: This test should be an error
             xfant::ExampleTest.testShouldErr (ExampleTest.fan:23)
             ...
          </error>
        </testcase>
        <testcase name='testShouldSkip' classname='xfant::ExampleTest' time='0'>
          <skipped/>
        </testcase>        
      </testsuite>
      ...
      <testsuite>
        <properties>
          <property name='java.version' value='9-internal'/>
          <property name='java.vm.name' value='OpenJDK 64-Bit Server VM'/>
        </properties>
      </testsuite>
    </testsuites>

The only difference is that `properties` (that are the environment variables) are repeated each `testsuite`. Xfant put the `properties` only one time after the `<testsuites>` tag, because the environment variables probably will be the same in all testsuites.

The output of Xfant will be:

    <testsuites>
      <properties>
        <property name='java.version' value='9-internal'/>
        <property name='java.vm.name' value='OpenJDK 64-Bit Server VM'/>
      </properties>
      <testsuite name='ExampleTest' classname='xfant::ExampleTest' time='0' tests='3' errors='1' failures='1' skipped='1' timestamp='2017-05-28T13:30:22.108+02:00'>
        <testcase name='testShouldPass' classname='xfant::ExampleTest' time='0'/>
        <testcase name='testShouldFail' classname='xfant::ExampleTest' time='0'>
          <failure message='Test failed: This test should be a failure' type='TestErr'>
            sys::TestErr: Test failed: This test should be a failure
            fan.sys.Test.err (Test.java:239)
            fan.sys.Test.fail (Test.java:231)
            ...
          </failure>
        </testcase>
        <testcase name='testShouldErr' classname='xfant::ExampleTest' time='0'>
          <error message='This test should be an error' type='Err'>
             sys::Err: This test should be an error
             xfant::ExampleTest.testShouldErr (ExampleTest.fan:23)
             ...
          </error>
        </testcase>
        <testcase name='testShouldSkip' classname='xfant::ExampleTest' time='0'>
          <skipped/>
        </testcase>
      </testsuite>
      ...
      <testsuite>
        <properties>
         ...
        </properties>
      </testsuite>
    </testsuites>

#### Hostname

In each `testsuite` an attribute named `hostname` is used. It is the host on which the tests were executed (`localhost` should be used if the hostname cannot be determined). This is not implemented.

#### System output and System err output

During the execution of tests the standard output and the standard error must be captured to further examination. This is not implemented yet.

### Xfant design

Xfant design in UML:

![Xfant design](http://eggbox.fantomfactory.org/pods/afFant/doc/fan://xfant/doc/xfant-design.svg)

