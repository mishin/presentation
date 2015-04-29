Fix a translation of to ruby from php (ru)

https://github.com/ruby/www.ruby-lang.org/pull/1067

Hi @mishin! Thank you for your contribution. Could you edit the title of your pull requests to be more specific (click edit button to edit it):

screenshot 2015-04-29 23 44 51

So that people could know each pull request's purpose, and can review your pull request.

Also could you please update the commit message to be more specific. To edit your commit message.

You can open Terminal, clone your forked branch:

git clone git@github.com:mishin/www.ruby-lang.org.git

Checkout to this pull request's branch (patch-10, see below picture):

screenshot 2015-04-29 23 42 21

git checkout patch-10

Edit your commit message:

git commit --amend

Now edit your commit message to something like:

Fix a translation of to ruby from php (ru)

Save. Then override this pull request's change:

git push -f origin patch-10

Then the commit message will be updated.

If you encounter any problem, please tell me. I'll help you. Thanks!
@mishin 
