+++
title = 'You Should Delete Tests'
date = 2025-06-30T02:36:27-07:00
draft = true
+++

We’ve had decades of thought leadership around testing, especially coming from wholistic development philosophies like Agile, TDD, and BDD. After all that time and several supposedly superseding movements, the developers I talk to seem to have developed a folk wisdom around tests.

That consensus seems to boil down to simple but mostly helpful axioms, like “include tests for your changes” and “write a new test when you fix a bug to prevent regressions”. Unfortunately, one of those consensus beliefs seems to be “it is blasphemy to delete a test”, and that belief is not just wrong but actively harmful.

Let’s talk about why you should delete tests.

To know why we should delete tests, let’s start with why we write tests in the first place. Why do we write tests? At the surface level, it’s to see if our program works the way we expect. But that doesn’t explain why we would write automated tests, rather than simply observe if the results of running our program are correct.

If you’ve ever tried to work on a project with no tests, I’m sure you’ve experienced the sinking sensation of backing yourself into a corner over time. The longer the project runs, the worse it gets, and eventually every possible change includes stressfully wondering if you broke something, wondering what you missed, and frantically deploying fix after revert after fix after revert as fast as possible because each frantic fix broke something else.

That nightmare is why automated tests exist: we need to be able to write software with confidence that we aren’t accidentally breaking everything we made before. The bigger a project gets, the more possible failures there are, and the more tests you need to have confidence it all works.

Confidence is the point of writing tests.

You run the tests so you can be confident when you open a pull request. CI runs the tests so you can be confident when you merge. CD runs the tests so you can be confident when you deploy. Tests exist to increase human confidence that a change will succeed.

Now that we know why tests exist, we can extrapolate when tests need to stop existing: any time they are decreasing confidence in a change.

How can a test possibly decrease confidence, you ask?

Let’s start with easy mode: it’s flaky. “Oh, it’s failing because of that flaky test, it’s actually fine” is something I have heard more times than I can count, but often the author is wrong and their code is actually broken. If your test is creating confidence in broken code with failing tests, it would be better for it to not exist. Delete the tests.

That’s not the only reason, though. What if your tests are written so that a one line code change means updating 150 tests? Do you really need 150 checks to see if your change actually worked? Delete the tests.

What if your tests take so long to run that you can’t run them all between merges, and you start skipping some? A skipped test doesn’t get run, but people act like it’s green—that’s another kind of flaky test, delivering a false pass instead of a false failure. You will get bitten by the mismatch, if you have any tests that don’t get run. Delete the tests.

Even worse, what if your business requirements have changed, and now you have thousands of lines of tests failing because they test the wrong thing? Updating irrelevant tests to pass isn’t going to increase your confidence in the new behavior. You don’t need to update the old tests, you need to test the new behavior directly. Delete the tests.
