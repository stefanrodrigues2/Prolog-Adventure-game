/* <The name of this game>, by <your name goes here>. */

:- dynamic i_am_at/1, at/2, holding/1, lives/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

i_am_at(campsite).

path(campsite, left, shelter).
path(shelter, right, campsite).

path(campsite, down, woods_1) :- flashlight_on.
path(campsite,down,woods_1) :- at(flashlight,holding),
        write('You need a battery to turn on the flashlight. Get a battery from the shack.'), nl,
        !, fail.
path(campsite,down,woods_1) :- 
        write('You need light to go into the woods. Grab a flashlight with a battery. '), nl,
        !, fail.
path(woods_1,up,campsite).

path(campsite, right, woods) :- flashlight_on.
path(campsite,right, woods) :- at(flashlight,holding),
        write('You need a battery to turn on the flashlight. Get a battery from the shack.'), nl,
        !, fail.
path(campsite,right,woods) :- 
        write('You need light to go into the woods. Grab a flashlight with a battery. '), nl,
        !, fail.
path(woods,left,campsite).

path(campsite,up,shack) :- at(key,holding).
path(campsite,up,shack) :-
        write('The shack is locked, Please get the key from the shelter.'), nl,
        !, fail.
path(shack,down,campsite).

path(woods,right,castle) :-
        write('You are at the castle, but do you have a blueprint to find the treasure? '),
        !,nl.
path(castle,left,woods).

path(castle,up,tower).
path(tower,down,castle) :- at(blueprint,holding),
        write('You have the blueprint. Use find. to get the treasure. '),
        !,nl.
path(tower,down,castle) :-
        write('Did you get the blueprint from the tower? or you forgot to collect it?. '),
        !,nl.

path(castle,down,deepforest_4) :-
        use_lives,
        write('Bad luck. Go back to save yourself.'), nl.
path(deepforest_4,up,castle) :-
        write('You are at the castle, but do you have a blueprint to find the treasure? '),
        !,nl.

path(castle,right,deepforest_3) :-
        use_lives,
        write('Bad luck. Go back to save yourself.'), nl.

path(deepforest_3,left,castle) :-
        write('You are at the castle, but do you have a blueprint to find the treasure? '),
        !,nl.

path(woods,up,deepforest_1) :- 
        use_lives,
        write('Bad luck. Go back to save yourself.'), nl.
path(deepforest_1,down,woods).

path(woods,down,deepforest_2) :-
        use_lives,
        write('Bad luck. Go back to save yourself.'), nl.
path(deepforest_2,up,woods).

/* Define where items are */

at(flashlight, campsite).
at(battery,shack).
at(key,shelter).
at(blueprint,tower).
flashlight_on :- at(flashlight,holding),at(battery,holding).

/* 3 Lives in total. */ 

lives(3).

/* These rules describe how to pick up an object. */

take(X) :-
        at(X,holding),
        write('Already holding it.'),
        nl, !.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(at(X, holding)),
        ((X == 'treasure', write('CONGRATULATIONS!!! YOU HAVE THE TREASURE IN HAND. YOU WON!!.'), nl,halt); true),
        write('OK.'),
        nl, !.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        at(X,holding),
        i_am_at(Place),
        retract(at(X, holding)),
        assert(at(X, Place)),
        write('OK.'),
        !, nl.

drop(_) :-
        write('You dont have it!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

up :- go(up).

down :- go(down).

right :- go(right).

left :- go(left).

/* This rule will reduce the number of lives when player goes into deep forest. */


use_lives :-
        lives(X),
        Y is X - 1,
        retract(lives(X)),
        assert(lives(Y)),
        ((Y==1, write('Be careful. You just have 1 life left.'), nl); true),
        ((Y == 0, die); true),
        nl.

/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        !, look.

go(_) :-
        write('You can''t go that way.').

/* This rule will find the treasure if you have a blueprint. */

find :-
        i_am_at(castle),
        at(blueprint,holding),
        assert(at(treasure,castle)),
        write('AMAZING!!. You found the treasure.'), nl,
        write('Collect the treasure and finish the game.'),
        nl,!.

find :-
        i_am_at(castle),
        write('You dont have a blueprint to find the treasure.'),!,nl.

find :- 
        write('You are not at the castle.'),nl.


/* This rule tells how to look about you. */

look :-
        lives(X),
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),nl,
        write('You have '),write(X), write(' lives.'), nl.

/* Inventory of the player */
i :-
        at(_,holding),
        write('You are holding: '), nl,
        !,get_items.
i :- 
        write('You dont hold anything. '),nl.

/* Get the list of items currently under hold by the player. */

get_items :-
        at(X,holding),
        write(X),nl,
        fail.
get_items.

/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).


/* This rule tells how to die. */

die :-
        finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('You walked in to the deep forest again.'), nl,
        write('You have 0 lives left. GAME OVER!!. '),
        halt.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.                  -- to start the game.'), nl,
        write('up. down. right. left.  -- to go in that direction.'), nl,
        write('take(Object).           -- to pick up an object.'), nl,
        write('drop(Object).           -- to put down an object.'), nl,
        write('look.                   -- to look around you again.'), nl,
        write('i.                      -- list the inventory of items.'), nl,
        write('find.                   -- to find the treasure.'), nl,
        write('instructions.           -- to see this message again.'), nl,
        write('halt.                   -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */


describe(campsite) :-
        \+ at(flashlight, campsite),
        write('You are at the Campsite.'), !,nl.

describe(campsite) :-
        at(flashlight, campsite),
        write('You are at the campsite.'), nl,
        write('You can find a flashlight here which can'), nl,
        write('help you move forward.'), !, nl.

describe(shack) :-
        \+ at(battery,shack),
        write('You are inside the shack.'), !,nl.

describe(shack) :-
        at(battery,shack),
        write('You are inside the shack.'), nl,
        write('You can find the battery for the flashlight here.'),!, nl.

describe(shelter) :-
        \+ at(key,shelter),
        write('You are inside the shelter.'), !, nl.

describe(shelter) :-
        at(key,shelter),
        write('You are inside the shelter.'), nl,
        write('You can find the key to shack in here.'), !, nl.

describe(woods) :-
        write('You are in the woods.'), nl,
        write('Make sure your flashlight is on.'), nl.

describe(woods_1) :-
        write('You are in the woods.'), nl,
        write('Make sure your flashlight is on.'), nl.

describe(deepforest_1) :-
        write('You walked in to the deep forest.'), nl,
        write('You are about to lose 1 life.'), nl.

describe(deepforest_2) :-
        write('You walked in to the deep forest.'), nl,
        write('You are about to lose 1 life.'), nl.

describe(deepforest_3) :-
        write('You walked in to the deep forest.'), nl,
        write('You are about to lose 1 life.'), nl.

describe(deepforest_4) :-
        write('You walked in to the deep forest.'), nl,
        write('You are about to lose 1 life.'), nl.

describe(castle) :-
        write('You reached the castle. There is hidden treasure inside.'), nl,
        write('This is your chance to win.'), nl.

describe(tower) :-
        \+ at(blueprint,tower),
        write('You are inside the tower.'), !, nl.

describe(tower) :-
        at(blueprint,tower),
        write('You are inside the tower.'), nl,
        write('Grab the blueprint to unlock the hidden treasure.'), !, nl.