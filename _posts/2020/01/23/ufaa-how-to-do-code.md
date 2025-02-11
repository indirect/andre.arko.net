---
layout: post
title: "🩺 How to do Code Review"
microblog: false
guid: http://indirect-test.micro.blog/2020/01/24/ufaa-how-to-do-code/
post_id: 4971634
date: 2020-01-23T16:00:00-0800
lastmod: 2025-02-10T22:17:50-0800
type: post
url: /2020/01/23/ufaa-how-to-do-code/
---
<div class="callout">
These guidelines were provided by an anonymous benefactor. They are reposted here (with permission) in the hope that future code review discussions can start from this excellent basis. — André
</div>

As a reviewer you’re responsible for **improving safety**, **enforcing broadly agreed upon standards** and should use the opportunity to **teach and learn from your colleagues**.

## 🎯 The goal of code reviews

Code reviews have a few goals.

1. **⛑ Safety**

    The #1 priority in a code review is to provide a layer of safety to protect things from breaking for your users.

2. **🚔 Enforcement of broadly agreed upon standards**

    In the cases where there are broadly agreed upon standards that aren’t enforced by your test infrastructure we may need to enforce standards in reviews. Reviewers should never enforce standards that aren’t broadly agreed upon.

3. **🧠 Education and context sharing**

    Nobody comes to a company already knowing the stack. Code reviews provide a chance for us to learn from each other.

Authors are required to get an approval from any colleague in order to merge code, but that doesn’t give reviewers a license to block reviews for just any reason.

- **❌ No stylistic preferences**

    Linters enforce style guidelines. Reviewers shouldn’t push their personal preferences in a blocking code review.

- **❌ No blocking tips**

    Offering tips for how things could be improved is great, but reviewers shouldn’t block PRs on nits.

- **✅ Block unsafe or non-standard code**

    Only safety issues and broadly agreed upon standards that aren’t caught by the linter should block PRs.

### ⛑  Safety

The most important goal of a code review is to provide a layer of safety. The top priority of a reviewer is to look for risks that may have been missed. There are many known types of risks that folks will be looking for and many unknown risks that you’ll need to use your discretion to navigate.

**🔐 Security and privacy**

Any PR that introduces (or appears to introduce) a security or privacy issue should be blocked until the issue is resolved.

**🐛 Bugs**

Reviewers should be on the lookout for bugs where the product might not behave as intended by the author or could otherwise cause issues for users, integrity of our data, etc..

**🧨 Traps for other engineers**

If a method is called `renameUser` but it actually deletes the user we could expect future engineers to get confused and will be at risk of introducing bugs.

**🕸 System failures**

It’s not always easy to spot changes that could trigger cascading failures or instability of our systems. Reviewers should be on the lookout for how unexpected circumstances might impact the broader network.

**💸 Excessive costs**

If a change might impact our costs in a material way needs to be prepared for. Reviewers should prevent changes that could unexpectedly increase costs.

### 🚔 Enforcement of broadly agreed upon standards

Ideally all of our code base policies should be encoded as linters and tests, but sometimes the infrastructure doesn’t exist and we rely on engineers to enforce policy for broadly agreed upon standards.

Reviewers shouldn’t enforce standards that aren’t broadly agreed upon. If something has been posted in a widely read channel or at an all-hands it probably should be enforced.

### 🧠 Education and shared context

Nobody went to school for hacking on your company’s stack. Outside of software fundamentals all of us had to learn how to make things work while on the job. Code reviews are one of the best ways for us to share knowledge and context about different ways things are done or tricks we’ve figured out to get things done in better ways.

Reviewers should freely share questions they have about why things are done the way they’re done in a review or offer insights into how things are done elsewhere.

That being said, education and context sharing isn’t blocking. If as a reviewer you see something that’s safe and aligns to broadly agreed standards but could be done in a different way you should let the author know but approve the pull request unless there are other issues.

## 📚 Appendix A: Related Docs

- [A Guide to Mindful Communication in Code Reviews](https://kickstarter.engineering/a-guide-to-mindful-communication-in-code-reviews-48aab5282e5e) by Amy Ciavolino
