 # Magic Link

This repo shows how to install magic link authentication in an existing Lamdera app.
It is still a work-in-progress.

The app is at https://elm-magic-test.lamdera.app/, It was built by applying rules 
from our package to a bare-bones Lamdera counter app.

You should be able to sign up, sign in, and have at it.

The code is here, at https://github.com/jxxcarlson/counter-review-test.

- The bare-bones counter app is in counter-original-src/
- The review rule is in review/src/ReviewConfig.elm
- The result of applying the review rule to teh bare-bones code is in src

You can use the Makefile to manage things if you want to try this out:

- Make install: install magic-link authentication on the bare-bones app.
- Make uninstall: the inverse of the previous step

If you run make install, you will get an elm-review error message.  So far,
for me, this is a false positive.  Somethng to be fixed.  Also, I recommend
running the make install with lamdera live in the off position.

You will have to manage the Postmark secret youself to make this work.
See `src/Config.elm` for details.

I'm not happy about the number of rules that are applied.  Ninety-two! (This is the atomic number of uranium, not a good sign).  I would like to reduce the surface area of the auth package.

Part of the reason for the large surface area is that the auth code includes not just authentication, but the batteries needed to make it operational: seeding with atmospheric random numbers (the real deal, never fake), registration of users, a page to sign in and sign up, and an admin page so the administrator can see the user data.

I am hard-coded as the administrator; I'll change this so that it is  onfigurable.

More work to do, but I am getting there.  Once I am a bit more happy about the
code, I will ask you to look at it so I as to make it better.


