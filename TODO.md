== Long-Term

=== Advanced Parser

Currently, the parser does a single-pass check for a valid command, and passes
the remaining tokens in as a flat array. For example:

  "go north" => :go, ["north"]
  "go to tool shed" => :go_to, ["tool", "shed"]


The advanced parser would first break up the text by reserved keywords, such as
"to", "at", and "with". These would be used to provide additional context to
the invoked action via the arguments object. Using our previous example:

  "go north" => :go, ["north"]
  "go to tool shed" => :go, [:receiver => "tool shed"]

The same :go command would support both flat input (for directions) and
contextualised input (for locations) without need for aliasing. Of course, the
same functionality can be achieved for this simple example, but let us consider
a more complicated use case:

  "cast magic missile at goblin" => :cast, ["magic missile", :target => "goblin"]

The advanced parser allows the user to specify context without forcing the
developer to re-implement it on a per-action basis.

  "mix red potion and blue herb" =>
    :mix, ["red potion", "blue herb"]
  
  "cast sleep on goblin and ogre mage" =>
    :cast, ["sleep", :target => ["goblin", "ogre mage"]]
  
  "cast fireball at dragon with phoenix feather and red essence" =>
    :cast, ["fireball", :target => "dragon", :combo => "phoenix feather", "red essence"]

==== Reserved Keywords

"and": reverse-lookup
"at", "on": target
"to": receiver
"with": combination
