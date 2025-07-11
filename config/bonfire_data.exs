import Config

#### Base configuration

verbs = [
  "Boost",
  "Create",
  "Delete",
  "Edit",
  "Flag",
  "Follow",
  "Like",
  "Mention",
  "Message",
  "Read",
  "Reply",
  "Request",
  "See",
  "Tag"
]

config :needle, :search_path_fun, {Bonfire.Common.ExtensionBehaviour, :apps_to_scan}

# Search these apps/extensions for Verbs to index (i.e. they contain modules with a declare_verbs/0 function)
config :bonfire_data_access_control,
  search_path: [
    # :bonfire_me,
    :bonfire_boundaries

    # :bonfire_social,
    # :bonfire,
  ]

config :bonfire, :verb_names, verbs

# # FIXME on older elixir versions
# known_deps =
#   if Code.ensure_loaded?(Bonfire.Common.Extend),
#     do: Bonfire.Common.Extend.deps_tree_flat() || [],
#     else: []

# # |> IO.inspect(label: "deps in config", limit: :infinity)

# maybe_extension_module = fn extension, module, fallback ->
#   if extension in known_deps, do: module, else: fallback
# end

# # FIXME: in prod all extensions are loaded
# maybe_extension_schema = fn extension, module ->
#   maybe_extension_module.(extension, module, Needle.Pointer)
# end

#### Alias modules for readability
alias Needle.Pointer
alias Needle.Table

alias Bonfire.Data.AccessControl.Acl
alias Bonfire.Data.AccessControl.Circle
alias Bonfire.Data.AccessControl.Encircle
alias Bonfire.Data.AccessControl.Controlled
alias Bonfire.Data.AccessControl.InstanceAdmin
alias Bonfire.Data.AccessControl.Grant
alias Bonfire.Data.AccessControl.Verb

alias Bonfire.Data.ActivityPub.Actor
alias Bonfire.Data.ActivityPub.Peer
alias Bonfire.Data.ActivityPub.Peered

# alias Bonfire.Boundaries.Permitted
alias Bonfire.Data.AccessControl.Stereotyped

alias Bonfire.Data.Edges.Edge
alias Bonfire.Data.Edges.EdgeTotal

alias Bonfire.Data.Identity.Account
alias Bonfire.Data.Identity.Accounted
alias Bonfire.Data.Identity.AuthSecondFactor
alias Bonfire.Data.Identity.Caretaker
alias Bonfire.Data.Identity.CareClosure
alias Bonfire.Data.Identity.Character
alias Bonfire.Data.Identity.Credential
alias Bonfire.Data.Identity.Email
alias Bonfire.Data.Identity.ExtraInfo
alias Bonfire.Data.Identity.Named
alias Bonfire.Data.Identity.Self
alias Bonfire.Data.Identity.Settings
alias Bonfire.Data.Identity.User
alias Bonfire.Data.Identity.Alias

alias Bonfire.Data.Social.Activity
alias Bonfire.Data.Social.APActivity
alias Bonfire.Data.Social.Article
alias Bonfire.Data.Social.Bookmark
alias Bonfire.Data.Social.Boost
alias Bonfire.Data.Social.Created
alias Bonfire.Data.Social.Feed
alias Bonfire.Data.Social.FeedPublish
alias Bonfire.Data.Social.Flag
alias Bonfire.Data.Social.Follow
alias Bonfire.Data.Social.Like
alias Bonfire.Data.Social.Mention
alias Bonfire.Data.Social.Message
alias Bonfire.Data.Social.Post
alias Bonfire.Data.Social.PostContent
alias Bonfire.Data.Social.Profile
alias Bonfire.Data.Social.Replied
alias Bonfire.Data.Social.Request
alias Bonfire.Data.Social.Pin
alias Bonfire.Data.Social.Sensitive
alias Bonfire.Data.Social.Emoji

alias Bonfire.Pages.Page
alias Bonfire.Pages.Section

alias Bonfire.Classify.Category
alias Bonfire.Classify.Tree
alias Bonfire.Geolocate.Geolocation
alias Bonfire.Files
alias Bonfire.Files.Media
alias Bonfire.Tag
alias Bonfire.Tag.Tagged

#### Exto Stitching

## WARNING: This is the flaky magic bit. We use configuration to
## compile extra stuff into modules.  If you add new fields or
## relations to ecto models in a dependency, you must recompile that
## dependency for it to show up! You will probably find you need to
## `rm -Rf _build/*/lib/bonfire_data_*` a lot.

mixin = [foreign_key: :id, references: :id]
mixin_updatable = mixin ++ [on_replace: :update]
mixin_replaceable = mixin ++ [on_replace: :delete_if_exists]

common_assocs = %{
  ### Mixins

  # A summary of an object that can appear in a feed.
  # activity: quote(do: has_one(:activity, unquote(Activity), unquote(mixin))),

  # retrieves the Create activity
  activity: quote(do: has_one(:activity, unquote(Activity), foreign_key: :id, references: :id)),

  # Indicates the entity responsible for an activity. Sort of like creator, but transferrable. Used
  # during deletion - when the caretaker is deleted, all their stuff will be too.
  caretaker: quote(do: has_one(:caretaker, unquote(Caretaker), unquote(mixin))),
  object_caretaker:
    quote(do: has_one(:caretaker, unquote(Replied), foreign_key: :id, references: :object_id)),

  # Indicates the creator of an object
  # TODO: add :creator with join_through
  created: quote(do: has_one(:created, unquote(Created), unquote(mixin))),
  object_created:
    quote(do: has_one(:created, unquote(Created), foreign_key: :id, references: :object_id)),

  # Used for non-textual interactions such as likes and follows to indicate the other object.
  edge: quote(do: has_one(:edge, unquote(Edge), unquote(mixin))),

  # Adds a name that can appear in the user interface for an object. e.g. for an ACL.
  named: quote(do: has_one(:named, unquote(Named), unquote(mixin_updatable))),

  # CW/NSFW
  sensitive: quote(do: has_one(:sensitive, unquote(Sensitive), unquote(mixin_updatable))),
  object_sensitive:
    quote(do: has_one(:sensitive, unquote(Sensitive), foreign_key: :id, references: :object_id)),

  # Information about the content of posts, e.g. a scrubbed html body
  post_content: quote(do: has_one(:post_content, unquote(PostContent), unquote(mixin_updatable))),
  object_post_content:
    quote(
      do:
        has_one(:object_post_content, unquote(PostContent),
          foreign_key: :id,
          references: :object_id
        )
    ),

  # Information about a user or other object that they wish to make available
  profile: quote(do: has_one(:profile, unquote(Profile), unquote(mixin_updatable))),

  # A Character has a unique username and some feeds.
  character: quote(do: has_one(:character, unquote(Character), unquote(mixin_updatable))),

  # Information about the remote instance the object is from, if it is not local.
  peered: quote(do: has_one(:peered, unquote(Peered), unquote(mixin))),

  # ActivityPub actor information
  actor: quote(do: has_one(:actor, unquote(Actor), unquote(mixin))),

  # Threading information, for threaded discussions.
  replied: quote(do: has_one(:replied, unquote(Replied), unquote(mixin_updatable))),
  object_replied:
    quote(do: has_one(:replied, unquote(Replied), foreign_key: :id, references: :object_id)),

  # Tree info for categories (groups/topics)
  tree: quote(do: has_one(:tree, unquote(Tree), unquote(mixin_updatable))),
  object_tree: quote(do: has_one(:tree, unquote(Tree), foreign_key: :id, references: :object_id)),

  # Information that allows the system to identify special system-managed ACLS.
  stereotyped: quote(do: has_one(:stereotyped, unquote(Stereotyped), unquote(mixin))),

  # Settings data
  settings: quote(do: has_one(:settings, unquote(Settings), foreign_key: :id)),
  account:
    quote do
      has_one(:accounted, unquote(Accounted), foreign_key: :id)

      has_one(:account,
        through: [:accounted, :account]
      )
    end,

  # FIXME: use the object or edge/activity here?
  seen:
    quote(
      do:
        has_one(:seen, unquote(Edge),
          foreign_key: :id,
          references: :id,
          where: [table_id: "1A1READYSAW0RREADTH1STH1NG"]
        )
    ),
  object_seen:
    quote(
      do:
        has_one(:seen, unquote(Edge),
          foreign_key: :object_id,
          references: :id,
          where: [table_id: "1A1READYSAW0RREADTH1STH1NG"]
        )
    ),
  labelled:
    quote(
      do:
        has_one(:labelled, unquote(Edge),
          foreign_key: :id,
          references: :id,
          where: [table_id: "71ABE1SADDED0NT0S0METH1NGS"]
        )
    ),
  object_labelled:
    quote(
      do:
        has_one(:labelled, unquote(Edge),
          foreign_key: :object_id,
          references: :id,
          where: [table_id: "71ABE1SADDED0NT0S0METH1NGS"]
        )
    ),
  object_voted:
    quote(
      do:
        has_many(:object_voted, unquote(Edge),
          foreign_key: :object_id,
          references: :id,
          where: [table_id: "7S0C10CRAT1CDEM0S0FC0NSENT"]
        )
    ),
  vote: quote(do: has_one(:vote, unquote(Bonfire.Poll.Vote), unquote(mixin))),

  # Adds extra info that can appear in the user interface for an object. e.g. a summary or JSON-encoded data.
  extra_info: quote(do: has_one(:extra_info, unquote(ExtraInfo), unquote(mixin_updatable))),

  ### Counts

  follow_count:
    quote(
      do:
        has_one(:follow_count, unquote(EdgeTotal),
          foreign_key: :id,
          references: :id,
          where: [table_id: "70110WTHE1EADER1EADER1EADE"]
        )
    ),
  like_count:
    quote(
      do:
        has_one(:like_count, unquote(EdgeTotal),
          foreign_key: :id,
          references: :id,
          where: [table_id: "11KES11KET0BE11KEDY0VKN0WS"]
        )
    ),
  boost_count:
    quote(
      do:
        has_one(:boost_count, unquote(EdgeTotal),
          foreign_key: :id,
          references: :id,
          where: [table_id: "300STANN0VNCERESHARESH0VTS"]
        )
    ),

  ### Multimixins

  # Links to access control information for this object.
  controlled: quote(do: has_many(:controlled, unquote(Controlled), unquote(mixin))),
  object_controlled:
    quote(
      do: has_many(:controlled, unquote(Controlled), foreign_key: :id, references: :object_id)
    ),

  # Inserts the object into selected feeds.
  feed_publishes: quote(do: has_many(:feed_publishes, unquote(FeedPublish), unquote(mixin))),

  # Information that this object has some files + the actual files
  media:
    quote do
      has_many(:files, unquote(Files), unquote(mixin_replaceable))

      many_to_many(:media, unquote(Media),
        join_through: unquote(Files),
        unique: true,
        join_keys: [id: :id, media_id: :id],
        on_replace: :delete
      )
    end,
  object_media:
    quote do
      has_many(:files, unquote(Files), foreign_key: :id, references: :object_id)

      # WIP: Combined approach that merges both media from files and direct media objects
      # This directly models: LEFT JOIN bonfire_files_media AS b4 ON (b12.media_id = b4.id OR b4.id = b1.object_id)
      # many_to_many(:media, unquote(Media),
      #   join_through: unquote(Files),
      #   join_keys: [id: :object_id, media_id: :id],
      #   # where: [table_id: "B0NF1REMEDIA0F1LES1NVAR10VS"],
      #   on_replace: :delete,
      #   # Filter to also include media that are objects themselves
      #   where: [
      #     # {:fragment, "? = ? OR ? = ?", :media_id, parent_as(:object).object_id, :id, parent_as(:object).object_id}
      #   ]
      # )

      many_to_many(:media, unquote(Media),
        join_through: unquote(Files),
        unique: true,
        join_keys: [id: :object_id, media_id: :id],
        on_replace: :delete
      )
    end,

  # Information that this object tagged other objects.
  # + the actual tags
  tags:
    quote do
      has_many(:tagged, Tagged, unquote(mixin))

      many_to_many(:tags, unquote(Pointer),
        join_through: Tagged,
        unique: true,
        join_keys: [id: :id, tag_id: :id],
        on_replace: :delete
      )
    end,
  object_tags:
    quote do
      has_many(:tagged, Tagged,
        foreign_key: :id,
        references: :object_id
      )

      many_to_many(:tags, unquote(Pointer),
        join_through: Tagged,
        unique: true,
        join_keys: [id: :object_id, tag_id: :id],
        on_replace: :delete
      )
    end,

  ### Regular has_many associations

  # The objects which reply to this object.
  direct_replies:
    quote(do: has_many(:direct_replies, unquote(Replied), foreign_key: :reply_to_id)),
  # A recursive view of caretakers of caretakers of... used during deletion.
  care_closure: quote(do: has_many(:care_closure, unquote(CareClosure), foreign_key: :branch_id)),
  # Retrieves activities where we are the object. e.g. if we are a
  # post or a user, this could turn up activities from likes or follows.
  activities:
    quote(do: has_many(:activities, unquote(Activity), foreign_key: :object_id, references: :id)),

  ### Stuff I'm not sure how to categorise yet

  edge_emoji:
    quote(
      # Note: we can't load the ExtraInfo mixin instead of the virtual `Bonfire.Data.Social.Emoji` because it can also be `Media` for custom emoji
      do:
        has_one(:emoji, unquote(Pointer),
          foreign_key: :id,
          references: :table_id
        )
    ),

  # Used currently only for requesting to follow a user, but more general
  request: quote(do: has_one(:request, unquote(Request), unquote(mixin))),
  ranked:
    quote(
      do:
        has_many(:ranked, unquote(Bonfire.Data.Assort.Ranked),
          foreign_key: :item_id,
          references: :id
        )
    ),

  #  TODO: point to Pointer for more generic choices?
  choices:
    quote(
      do:
        many_to_many(:choices, unquote(Bonfire.Poll.Choice),
          join_through: unquote(Bonfire.Data.Assort.Ranked),
          unique: true,
          join_keys: [scope_id: :id, item_id: :id],
          on_replace: :delete
        )
    )
}

# retrieves a list of quoted forms suitable for use with unquote_splicing
common = fn names ->
  for name <- List.wrap(names) do
    with nil <- common_assocs[name],
         do:
           raise(RuntimeError,
             message: "Expected a common association name, got #{inspect(name)}"
           )
  end
end

edge =
  common.([
    :activity,
    :activities,
    :request,
    :post_content,
    :media,
    :named,
    :extra_info,
    # :object_media,
    :object_created,
    :object_caretaker,
    :object_replied,
    :object_tree,
    :object_sensitive,
    :object_labelled,
    :object_seen,
    :object_controlled,
    :object_tags,
    :object_voted,
    :vote,
    :edge_emoji
  ])

# FIXME? do we want to boundarise an edge by the object (:object_controlled - eg. the post) or the edge (:controlled - eg. the like)

edges =
  common.([
    # :edge,
    :named,
    :extra_info,
    :controlled,
    :activities,
    :request,
    :created,
    :replied,
    :caretaker,
    :activity,
    :feed_publishes,
    :follow_count,
    :boost_count,
    :like_count
  ])

# first up, Pointer could have all the mixins we're using

pointer_mixins =
  common.([
    :activity,
    :account,
    :actor,
    :caretaker,
    :character,
    :created,
    :edge,
    :named,
    :sensitive,
    :seen,
    :labelled,
    :extra_info,
    :peered,
    :post_content,
    :profile,
    :replied,
    :tree,
    :stereotyped,
    :settings,
    :follow_count,
    :boost_count,
    :like_count,
    :tags,
    :media,
    :controlled,
    :activities,
    :care_closure,
    :direct_replies,
    :feed_publishes,
    :ranked,
    :choices
  ])

config :needle, Pointer,
  code:
    (quote do
       field(:dummy, :any, virtual: true)
       # pointables
       has_one(:circle, unquote(Circle), foreign_key: :id)

       many_to_many(:encircle_subjects, Pointer,
         join_through: Encircle,
         join_keys: [circle_id: :id, subject_id: :id]
       )

       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)
       has_one(:user, unquote(User), foreign_key: :id)
       has_one(:post, unquote(Post), foreign_key: :id)
       has_one(:message, unquote(Message), foreign_key: :id)
       has_one(:category, unquote(Category), foreign_key: :id)
       has_one(:geolocation, unquote(Geolocation), foreign_key: :id)
       # mixins
       unquote_splicing(pointer_mixins)
     end)

config :needle, Table, []

# now let's weave everything else together for convenience
# bonfire_data_access_control

config :bonfire_data_access_control, Acl,
  code:
    (quote do
       field(:grants_count, :integer, virtual: true)
       field(:controlled_count, :integer, virtual: true)
       # mixins
       unquote_splicing(common.([:caretaker, :named, :extra_info]))

       # multimixins
       # unquote_splicing(common.([:controlled]))
     end)

config :bonfire_data_access_control, Circle,
  code:
    (quote do
       field(:encircles_count, :integer, virtual: true)
       # mixins
       unquote_splicing(common.([:caretaker, :named, :extra_info]))
       # multimixins
       unquote_splicing(common.([:controlled]))
     end)

config :bonfire_data_access_control, Controlled, []

config :bonfire_data_access_control, Encircle,
  code:
    (quote do
       has_one(:peer, unquote(Peer), foreign_key: :id, references: :subject_id)
     end)

config :bonfire_data_access_control, InstanceAdmin,
  code:
    (quote do
       belongs_to(:user, unquote(User))
     end)

config :bonfire_data_access_control, Grant,
  code:
    (quote do
       # mixins
       (unquote_splicing(common.([:caretaker])))

       # multimixins
       # unquote_splicing(common.([:controlled]))
     end)

config :bonfire_data_access_control, Verb, []

config :bonfire_boundaries, Stereotyped,
  code:
    (quote do
       has_one(:named, unquote(Named), foreign_key: :id, references: :stereotype_id)
     end)

# bonfire_data_activity_pub

config :bonfire_data_activity_pub, Actor,
  code:
    (quote do
       # hacks
       belongs_to(:character, unquote(Character), foreign_key: :id, define_field: false)
       belongs_to(:user, unquote(User), foreign_key: :id, define_field: false)
       # mixins
       unquote_splicing(common.([:peered]))
       # multimixins
       unquote_splicing(common.([:controlled]))
     end)

config :bonfire_data_activity_pub, Peer, []
config :bonfire_data_activity_pub, Peered, []

# bonfire_data_identity

config :bonfire_data_identity, Account,
  code:
    (quote do
       has_one(:credential, unquote(Credential), foreign_key: :id)
       has_one(:email, unquote(Email), foreign_key: :id)
       has_one(:auth_second_factor, unquote(AuthSecondFactor), foreign_key: :id)
       has_one(:settings, unquote(Settings), foreign_key: :id)
       has_one(:instance_admin, unquote(InstanceAdmin), foreign_key: :id, on_replace: :update)

       many_to_many(:users, unquote(User),
         join_through: Accounted,
         join_keys: [account_id: :id, id: :id]
       )

       # optional
       many_to_many(:shared_users, unquote(User),
         join_through: "bonfire_data_shared_user_accounts",
         join_keys: [account_id: :id, shared_user_id: :id]
       )
     end)

config :bonfire_data_identity, Accounted,
  code:
    (quote do
       # belongs_to(:account, Account) # NOTE: defined in schema
       belongs_to(:user, unquote(User), foreign_key: :id, define_field: false)
     end)

config :bonfire_data_identity, Caretaker,
  code:
    (quote do
       has_one(:user, unquote(User), foreign_key: :id, references: :caretaker_id)
       # mixins
       unquote_splicing(common.([:character, :profile]))
     end)

config :bonfire_data_identity, Character,
  code:
    (quote do
       @follow_ulid "70110WTHE1EADER1EADER1EADE"
       @alias_ulid "7NA11ASA1S0KN0WNASFACESWAP"

       # mixins
       unquote_splicing(common.([:actor, :peered, :profile, :tree, :follow_count]))
       has_one(:user, unquote(User), unquote(mixin))
       has_one(:feed, unquote(Feed), unquote(mixin))

       # TODO? link the Edge assocs directly to the subject or object instead of the Edge

       # aliases I added
       has_many(:aliases, unquote(Edge),
         foreign_key: :subject_id,
         references: :id,
         where: [table_id: @alias_ulid]
       )

       # aliases others add of me
       has_many(:aliased, unquote(Edge),
         foreign_key: :object_id,
         references: :id,
         where: [table_id: @alias_ulid]
       )

       has_many(:followers, unquote(Edge),
         foreign_key: :object_id,
         references: :id,
         where: [table_id: @follow_ulid]
       )

       has_many(:followed, unquote(Edge),
         foreign_key: :subject_id,
         references: :id,
         where: [table_id: @follow_ulid]
       )
     end)

config :bonfire_data_identity, Credential,
  code:
    (quote do
       belongs_to(:account, unquote(Account), foreign_key: :id, define_field: false)
     end)

config :bonfire_data_identity, Email,
  must_confirm: true,
  code:
    (quote do
       belongs_to(:account, unquote(Account), foreign_key: :id, define_field: false)
     end)

config :bonfire_data_identity, Self, []

config :bonfire_data_identity, User,
  code:
    (quote do
       @like_ulid "11KES11KET0BE11KEDY0VKN0WS"
       @boost_ulid "300STANN0VNCERESHARESH0VTS"
       @follow_ulid "70110WTHE1EADER1EADER1EADE"
       # mixins
       unquote_splicing(
         common.([
           :account,
           :actor,
           :character,
           :created,
           :peered,
           :profile,
           :settings,
           :sensitive,
           :tags
         ])
       )

       has_one(:self, unquote(Self), foreign_key: :id)

       has_one(
         :shared_user,
         Bonfire.Data.SharedUser,
         #  unquote(maybe_extension_schema.(:bonfire_data_shared_user, Bonfire.Data.SharedUser)), # FIXME
         foreign_key: :id
       )

       has_one(:instance_admin, unquote(InstanceAdmin),
         foreign_key: :user_id,
         on_replace: :update
       )

       #  has_one(:instance_admin,
       #    through: [:account, :instance_admin]
       #  )

       # multimixins
       unquote_splicing(common.([:controlled]))
       # manies
       has_many(:encircles, unquote(Encircle), foreign_key: :subject_id)
       # todo: stop through
       has_many(:creations, through: [:created, :pointer])
       # todo: stop through
       has_many(:posts, through: [:created, :post])

       has_many(:followers, unquote(Edge),
         foreign_key: :object_id,
         references: :id,
         where: [table_id: @follow_ulid]
       )

       has_many(:followed, unquote(Edge),
         foreign_key: :subject_id,
         references: :id,
         where: [table_id: @follow_ulid]
       )

       has_many(:user_activities, unquote(Activity), foreign_key: :subject_id, references: :id)

       has_many(:boost_activities, unquote(Edge),
         foreign_key: :subject_id,
         references: :id,
         where: [table_id: @boost_ulid]
       )

       has_many(:like_activities, unquote(Edge),
         foreign_key: :subject_id,
         references: :id,
         where: [table_id: @like_ulid]
       )

       many_to_many(:caretaker_accounts, unquote(Account),
         join_through: "bonfire_data_shared_user_accounts",
         join_keys: [shared_user_id: :id, account_id: :id]
       )

       # has_many :account, through: [:accounted, :account] # this is private info, do not expose
       # has_one :geolocation, Bonfire.Geolocate.Geolocation # enable if using Geolocate extension
     end)

config :bonfire_data_identity, Named, []
config :bonfire_data_identity, ExtraInfo, []

config :bonfire_data_identity, Alias,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

### bonfire_data_social

config :bonfire_data_social, Activity,
  code:
    (quote do
       @like_ulid "11KES11KET0BE11KEDY0VKN0WS"
       @boost_ulid "300STANN0VNCERESHARESH0VTS"
       @follow_ulid "70110WTHE1EADER1EADER1EADE"

       # mixins (note most should be linked to the object rather than the activity)
       (unquote_splicing(
          common.([
            :named,
            :edge,
            :feed_publishes,
            :object_media,
            :object_post_content,
            :object_created,
            :object_caretaker,
            :object_replied,
            :object_tree,
            :object_sensitive,
            :object_labelled,
            :object_seen,
            :object_controlled,
            :object_tags
          ])
        ))

       # ugly workaround needed for certain queries (TODO: check if still needed)
       has_one(:activity, unquote(Activity), foreign_key: :id, references: :id)

       # Virtuals
       field(:path, EctoMaterializedPath.UIDs, virtual: true)
       field(:federate_activity_pub, :any, virtual: true)

       # Edge counts
       has_one(:like_count, unquote(EdgeTotal),
         foreign_key: :id,
         references: :object_id,
         where: [table_id: @like_ulid]
       )

       has_one(:boost_count, unquote(EdgeTotal),
         foreign_key: :id,
         references: :object_id,
         where: [table_id: @boost_ulid]
       )

       has_one(:follow_count, unquote(EdgeTotal),
         foreign_key: :id,
         references: :object_id,
         where: [table_id: @follow_ulid]
       )

       # has_one(:like, unquote(Edge),
       #   foreign_key: :id,
       #   references: :id,
       #   where: [verb_id: "11KES11KET0BE11KEDY0VKN0WS"]
       # )

       has_one(:emoji,
         through: [:edge, :emoji]
       )
     end)

config :bonfire_data_social, APActivity,
  code:
    (quote do
       (unquote_splicing(
          common.([
            :created,
            :peered,
            :activity,
            :caretaker,
            :controlled,
            :media,
            :profile,
            :character,
            :post_content,
            :feed_publishes
          ])
        ))

       # FIXME: find how to avoid declaring unused mixins here (eg. post_content) without it causing repo.preload to crash
     end)

config :bonfire_data_edges, Edge,
  code:
    (quote do
       (unquote_splicing(edge))

       # TODO: requires composite foreign keys:
       # has_one :activity, unquote(Activity),
       #   foreign_key: [:table_id, :object_id], references: [:table_id, :object_id]
     end)

config :bonfire_data_social, Feed,
  code:
    (quote do
       # mixins
       (unquote_splicing(common.([:activity, :caretaker])))

       # belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
       # belongs_to :user, unquote(User), foreign_key: :id, define_field: false
     end)

config :bonfire_data_social, FeedPublish,
  code:
    (quote do
       field(:dummy, :any, virtual: true)
       has_one(:activity, unquote(Activity), foreign_key: :id, references: :id)

       # belongs_to :character, unquote(Character), foreign_key: :id, define_field: false
       # belongs_to :user, unquote(User), foreign_key: :id, define_field: false
     end)

config :bonfire_data_social, Follow,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

# belongs_to: [follower_character: {Character, foreign_key: :follower_id, define_field: false}],
# belongs_to: [follower_profile: {Profile, foreign_key: :follower_id, define_field: false}],
# belongs_to: [followed_character: {Character, foreign_key: :followed_id, define_field: false}],
# belongs_to: [followed_profile: {Profile, foreign_key: :followed_id, define_field: false}]

config :bonfire_data_social, Boost,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

# has_one:  [activity: {Activity, foreign_key: :object_id, references: :boosted_id}] # requires an ON clause

config :bonfire_label, Bonfire.Label,
  code:
    (quote do
       unquote_splicing(edges)

       unquote_splicing(
         common.([
           #  :created,
           :media,
           :post_content
         ])
       )
     end)

config :bonfire_data_social, Emoji,
  code:
    (quote do
       (unquote_splicing(
          common.([
            :media,
            :extra_info
          ])
        ))
     end)

config :bonfire_data_social, Like,
  code:
    (quote do
       (unquote_splicing(edges))

       has_one(:emoji,
         through: [:edge, :emoji]
       )
     end)

# has_one:  [activity: {Activity, foreign_key: :object_id, references: :liked_id}] # requires an ON clause

config :bonfire_data_social, Pin,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

config :bonfire_data_social, Flag,
  code:
    (quote do
       (unquote_splicing(edges))

       unquote_splicing(
         common.([
           #  :named
         ])
       )
     end)

config :bonfire_data_social, Request,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

config :bonfire_data_social, Bookmark,
  code:
    (quote do
       (unquote_splicing(edges))
     end)

config :bonfire_data_social, Message,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :activity,
           :caretaker,
           :created,
           :peered,
           :post_content,
           :replied,
           :like_count,
           #  :boost_count,
           :sensitive
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :feed_publishes, :tags, :media]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_data_social, Mention, []

config :bonfire_data_social, Post,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :named,
           :activities,
           :activity,
           :caretaker,
           :created,
           :peered,
           :post_content,
           :replied,
           :tree,
           :like_count,
           :boost_count,
           :labelled,
           :sensitive,
           :extra_info
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :media, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
       # special
       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)
       # has_one:  [creator_user: {[through: [:created, :creator_user]]}],
       # has_one:  [creator_character: {[through: [:created, :creator_character]]}],
       # has_one:  [creator_profile: {[through: [:created, :creator_profile]]}],
       # has_one :activity, unquote(Activity), foreign_key: :object_id, references: :id # requires an ON clause
       # has_one:  [reply_to: {[through: [:replied, :reply_to]]}],
       # has_one:  [reply_to_post: {[through: [:replied, :reply_to_post]]}],
       # has_one:  [reply_to_post_content: {[through: [:replied, :reply_to_post_content]]}],
       # has_one:  [reply_to_creator_character: {[through: [:replied, :reply_to_creator_character]]}],
       # has_one:  [reply_to_creator_profile: {[through: [:replied, :reply_to_creator_profile]]}],
       # has_one:  [thread_post: {[through: [:replied, :thread_post]]}],
       # has_one:  [thread_post_content: {[through: [:replied, :thread_post_content]]}],
     end)

config :bonfire_data_social, PostContent,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:created, :named, :activity]))
       # multimixins
       unquote_splicing(common.([:controlled]))
       # virtuals for changesets
       field(:hashtags, {:array, :any}, virtual: true)
       field(:mentions, {:array, :any}, virtual: true)
       field(:urls, {:array, :any}, virtual: true)
     end)

config :bonfire_data_social, Replied,
  code:
    (quote do
       # multimixins
       unquote_splicing(common.([:activities, :activity, :controlled, :like_count, :boost_count]))

       belongs_to(:post, unquote(Post), foreign_key: :id, define_field: false)
       belongs_to(:post_content, unquote(PostContent), foreign_key: :id, define_field: false)

       # used for sorting reply threads
       field(:path_sorter, :any, virtual: true)

       # FIXME? won't show pins of custom type (eg. answer)
       has_one(:pinned, unquote(Edge),
         foreign_key: :object_id,
         references: :id,
         where: [table_id: "1P1NS0METH1NGT0H1GH11GHT1T"]
       )

       # NOTE: query requires an ON clause to filter by thread
       #  has_one(:pinned, unquote(Pin), foreign_key: :id, references: :id)
       # has_one(:pinned_edge, through: [:pinned, :edge])
       #  has_one(:pins_in_thread, unquote(Edge), # FIXME? won't show pins of custom type (eg. answer)
       #    foreign_key: :subject_id,
       #    references: :thread_id,
       #    where: [table_id: "1P1NS0METH1NGT0H1GH11GHT1T"]
       #  )

       # used in changesets
       field(:replying_to, :map, virtual: true)
       has_one(:reply_to_post, unquote(Post), foreign_key: :id, references: :reply_to_id)

       has_one(:reply_to_post_content, unquote(PostContent),
         foreign_key: :id,
         references: :reply_to_id
       )

       has_one(:reply_to_created, unquote(Created), foreign_key: :id, references: :reply_to_id)
       # has_one  :reply_to_creator_user, through: [:reply_to_created, :creator_user]
       # has_one  :reply_to_creator_character, through: [:reply_to_created, :creator_character]
       # has_one  :reply_to_creator_profile, through: [:reply_to_created, :creator_profile]
       has_many(:direct_replies, unquote(Replied), foreign_key: :reply_to_id, references: :id)
       has_many(:thread_replies, unquote(Replied), foreign_key: :thread_id, references: :id)
       has_one(:thread_post, unquote(Post), foreign_key: :id, references: :thread_id)

       has_one(:thread_post_content, unquote(PostContent),
         foreign_key: :id,
         references: :thread_id
       )
     end)

config :bonfire_data_social, Created,
  code:
    (quote do
       belongs_to(:creator_user, unquote(User), foreign_key: :creator_id, define_field: false)

       belongs_to(:creator_character, unquote(Character),
         foreign_key: :creator_id,
         define_field: false
       )

       belongs_to(:creator_profile, unquote(Profile),
         foreign_key: :creator_id,
         define_field: false
       )

       # mixins - shouldn't be here really
       unquote_splicing(common.([:peered]))
       # huh?
       has_one(:post, unquote(Post), unquote(mixin))
     end)

config :bonfire_data_social, Profile,
  code:
    (quote do
       belongs_to(:user, unquote(User), foreign_key: :id, define_field: false)

       belongs_to(:icon, Bonfire.Files.Media)
       belongs_to(:image, Bonfire.Files.Media)

       # multimixins - shouldn't be here really
       unquote_splicing(common.([:controlled]))
     end)

######### other extensions

config :bonfire_pages, Page,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :activities,
           :activity,
           :caretaker,
           :created,
           :post_content,
           :like_count,
           :boost_count
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :media, :feed_publishes, :ranked]))

       # special
       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)

       # add references of page sections
       many_to_many(:sections, unquote(Pointer),
         join_through: unquote(Bonfire.Data.Assort.Ranked),
         unique: true,
         join_keys: [scope_id: :id, item_id: :id],
         on_replace: :delete
       )
     end)

config :bonfire_pages, Section,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :activities,
           :activity,
           :caretaker,
           :created,
           :post_content,
           :like_count,
           :boost_count
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :media, :feed_publishes, :ranked]))

       # special
       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)

       # add references of page sections
       many_to_many(:pages, unquote(Pointer),
         join_through: unquote(Bonfire.Data.Assort.Ranked),
         unique: true,
         join_keys: [item_id: :id, scope_id: :id],
         on_replace: :delete
       )
     end)

config :bonfire_files, Media,
  code:
    (quote do
       field(:url, :string, virtual: true)
       # multimixins - shouldn't be here really
       unquote_splicing(common.([:controlled, :created, :activity, :caretaker, :peered]))
     end)

config :bonfire_tag, Tagged,
  code:
    (quote do
       has_one(:named, Named, foreign_key: :id, references: :tag_id)

       # mixins
       (unquote_splicing(common.([:activity])))
     end)

config :bonfire_classify, Category,
  code:
    (quote do
       # mixins
       # TODO :caretaker
       unquote_splicing(
         common.([:activity, :created, :actor, :peered, :profile, :character, :settings])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :feed_publishes]))

       has_one(:creator, through: [:created, :creator])

       # add references of tagged objects to any Category
       many_to_many(:tags, unquote(Pointer),
         join_through: Tagged,
         unique: true,
         join_keys: [tag_id: :id, id: :id],
         on_replace: :delete
       )
     end)

config :bonfire_geolocate, Bonfire.Geolocate.Geolocation,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([:activity, :caretaker, :created, :actor, :peered, :profile, :character])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
     end)

config :bonfire_valueflows, ValueFlows.EconomicEvent,
  code:
    (quote do
       # mixins
       # TODO :caretaker
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.EconomicResource,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Knowledge.ResourceSpecification,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Process,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Knowledge.ProcessSpecification,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Planning.Intent,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Planning.Commitment,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows, ValueFlows.Proposal,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_valueflows_observe, ValueFlows.Observe.Observation,
  code:
    (quote do
       # mixins
       unquote_splicing(common.([:activity, :caretaker, :peered, :replied]))
       # multimixins
       unquote_splicing(common.([:controlled, :tags, :feed_publishes]))
       # has
       unquote_splicing(common.([:direct_replies]))
     end)

config :bonfire_poll, Bonfire.Poll.Question,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :activities,
           :activity,
           :caretaker,
           :created,
           :post_content,
           :like_count,
           :boost_count
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :media, :feed_publishes, :ranked, :choices]))

       # special
       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)

       #  has_many :voted, through: [:choices, :voted]
     end)

config :bonfire_poll, Bonfire.Poll.Choice,
  code:
    (quote do
       # mixins
       unquote_splicing(
         common.([
           :activities,
           :activity,
           :caretaker,
           :created,
           :post_content,
           :like_count,
           :boost_count,
           :object_voted
         ])
       )

       # multimixins
       unquote_splicing(common.([:controlled, :tags, :media, :feed_publishes, :ranked]))

       # special
       #  has_one(:permitted, unquote(Permitted), foreign_key: :object_id)

       # add references of page sections
       many_to_many(:questions, unquote(Pointer),
         join_through: unquote(Bonfire.Data.Assort.Ranked),
         unique: true,
         join_keys: [item_id: :id, scope_id: :id],
         on_replace: :delete
       )
     end)

config :bonfire_poll, Bonfire.Poll.Vote,
  code:
    (quote do
       (unquote_splicing(edges))
     end)
