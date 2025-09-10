# Script for populating the database. You can run it with `just mix ecto.seeds`
#
use Bonfire.Common.E
import Bonfire.Me.Fake
import Bonfire.Social.Fake
import Bonfire.Posts.Fake

# Configure scale of seed data - adjust as needed
num_users = 3
num_posts = 10
num_comments_per_post = 50
num_categories = 3
num_locations = 3

# Environment setup
System.put_env("SEARCH_INDEXING_DISABLED", "true")
Application.put_env(:bonfire, :invite_only, false)
# Configure anti-spam to use mock version for seeds
Application.put_env(:bonfire_common, Bonfire.Common.AntiSpam,
  service: Bonfire.Common.AntiSpam.Mock
)

# Create admin user if credentials are provided
case {System.get_env("ADMIN_USER", "root"), System.get_env("ADMIN_PASSWORD", "")} do
  {name, password} when byte_size(password) > 0 ->
    fake_account!(%{credential: %{password: password}})
    |> fake_user!(%{username: name, name: name})
    |> Bonfire.Me.Users.make_admin()

    IO.puts("[seeds] Created admin user: #{name}")

  _ ->
    IO.puts("[seeds] Did not create admin user")
end

# Create regular users
IO.puts("[seeds] Creating #{num_users} users...")
users = for _ <- 1..num_users, do: fake_user!()
random_user = fn -> Faker.Util.pick(users) end

# Helper function to maybe return an item or nil
maybe_one_of = fn list ->
  case Enum.empty?(list) do
    true -> nil
    false -> if Enum.random([true, false]), do: Faker.Util.pick(list), else: nil
  end
end


for %{preset: preset, filters: _filters} = params
      when preset not in [:my, :audio, :videos, :user_followers, :user_following, :flagged_content,
             :trending_links,
              :trending_discussions,
              :trending] <- feed_preset_test_params() do
  IO.puts("[seeds] Creating data for #{preset}...")
  for i <- 1..num_posts do
    create_test_content(preset, random_user.(), random_user.(), i)
  end
end


# Start creating posts with different types
IO.puts("[seeds] Creating #{num_posts} posts...")

posts = for _ <- 1..num_posts do
  # Select post type (regular post, post with hashtag, or post with mention)
  post_type = Enum.random([:regular, :hashtag, :mention])
  
  case post_type do
    :regular ->
      fake_post!(random_user.(), "local")
      
    :hashtag ->
      # Create post with hashtag
      fake_post!(
        random_user.(), 
        "local",
        %{
          post_content: %{
            html_body: "<p>#{Faker.Lorem.paragraph()} ##{Faker.Internet.slug()}</p>"
          }
        }
      )
      
    :mention ->
      # Create post that mentions another user
      mentioned_user = random_user.()
      fake_post!(
        random_user.(), 
        "local",
        %{
          post_content: %{
            html_body: "<p>#{Faker.Lorem.paragraph()} @#{mentioned_user.character.username}</p>"
          }
        }
      )
  end
end

# Add comments and replies to posts
IO.puts("[seeds] Adding comments to posts...")
for post <- posts do
  # Create a random number of comments for each post
  comments_count = :rand.uniform(num_comments_per_post)
  
  # Create first level comments
  comments = for _ <- 1..comments_count do
    fake_comment!(random_user.(), post)
  end
  
  # Add replies to some comments
  for comment <- Enum.take_random(comments, div(comments_count, 2)) do
    # Create reply to comment
    reply = fake_comment!(random_user.(), comment)
    
    # Sometimes create a deeper reply chain
    if Enum.random([true, false]) do
      subreply = fake_comment!(random_user.(), reply)
      # Potentially go even deeper
      if Enum.random([true, false]) do
        fake_comment!(random_user.(), subreply)
      end
    end
  end
end

# Create social graph interactions (follows, likes, boosts)
IO.puts("[seeds] Creating social interactions...")

# Create follows between users
for _ <- 1..(num_users * 2) do
  follower = random_user.()
  followed = random_user.()
  
  # Avoid self-follows
  if follower.id != followed.id do
    Bonfire.Social.Graph.Follows.follow(follower, followed)
  end
end

# Add likes to some posts
IO.puts("[seeds] Adding likes to posts...")
for post <- Enum.take_random(posts, div(length(posts), 2)) do
  # Get a random subset of users to like each post
  like_count = Enum.random(1..3)
  liking_users = users |> Enum.shuffle() |> Enum.take(like_count)
  
  # Have each selected user like the post
  for user <- liking_users do
    Bonfire.Social.Likes.like(user, post)
  end
end

# Add boosts to some posts
for post <- Enum.take_random(posts, div(length(posts), 3)) do
  Bonfire.Social.Boosts.boost(random_user.(), post)
end

# Define categories/tags (if extension enabled)
if Bonfire.Common.Extend.extension_enabled?(Bonfire.Classify.Simulate) do
  IO.puts("[seeds] Creating categories and tags...")
  
  categories = for _ <- 1..num_categories do
    category = Bonfire.Classify.Simulate.fake_category!(random_user.())
    
    # Create subcategories
    for _ <- 1..2 do
      subcategory = Bonfire.Classify.Simulate.fake_category!(random_user.(), category)
      
      # Sometimes create even deeper category hierarchies
      if Enum.random([true, false]) do
        Bonfire.Classify.Simulate.fake_category!(random_user.(), subcategory)
      end
    end
    
    category
  end
  
  # Tag some posts with categories
  for post <- Enum.take_random(posts, div(length(posts), 2)) do
    category = Faker.Util.pick(categories)
    if function_exported?(Bonfire.Classify.Categories, :tag, 3) do
      Bonfire.Classify.Categories.tag(random_user.(), post, category)
    end
  end
end

# Define geolocations (if extension enabled)
places = if Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate) do
  IO.puts("[seeds] Creating geolocations...")
  
  # Create standalone geolocations
  places = for _ <- 1..num_locations do
    Bonfire.Geolocate.Simulate.fake_geolocation!(random_user.())
  end
  
  # Attach locations to some posts
  for post <- Enum.take_random(posts, div(length(posts), 3)) do
    place = Faker.Util.pick(places)
    if function_exported?(Bonfire.Geolocate, :geolocation_add, 3) do
      Bonfire.Geolocate.geolocation_add(random_user.(), post, place)
    end
  end

  places
end

# Define units of measurement (if extension enabled)
units = if Bonfire.Common.Extend.extension_enabled?(Bonfire.Quantify.Simulate) do
  IO.puts("[seeds] Creating units of measurement...")
  
  for _ <- 1..3 do
    Bonfire.Quantify.Simulate.fake_unit!(random_user.())
  end
end

# Create ValueFlows economic activities (if extension enabled)
if Bonfire.Common.Extend.extension_enabled?(ValueFlows.Simulate) do
  IO.puts("[seeds] Creating ValueFlows economic activities...")
  
  # Create specifications
  process_specs = for _ <- 1..2 do
    ValueFlows.Simulate.fake_process_specification!(random_user.())
  end
  
  resource_specs = for _ <- 1..2 do
    ValueFlows.Simulate.fake_resource_specification!(random_user.())
  end
  
  # Create intents and proposals
  for _ <- 1..3 do
    user = random_user.()
    action_id = ValueFlows.Simulate.action_id()
    
    # Create intent
    intent = ValueFlows.Simulate.fake_intent!(
      user, 
      %{
        resource_conforms_to: Faker.Util.pick(resource_specs),
        action_id: action_id
      }
    )
    
    # Create proposal and connect to intent
    proposal = ValueFlows.Simulate.fake_proposal!(user)
    ValueFlows.Simulate.fake_proposed_to!(random_user.(), proposal)
    ValueFlows.Simulate.fake_proposed_intent!(proposal, intent)
    
    # If geolocation is available, add locations to some intents and proposals
    if Bonfire.Common.Extend.extension_enabled?(Bonfire.Geolocate.Simulate) and 
       length(places || []) > 0 do
      
      random_place = fn -> Faker.Util.pick(places) end
      
      # Create intents and proposals with locations
      geo_intent = ValueFlows.Simulate.fake_intent!(
        random_user.(),
        %{
          at_location: random_place.(),
          action_id: action_id
        }
      )
      
      geo_proposal = ValueFlows.Simulate.fake_proposal!(
        user, 
        %{
          eligible_location: random_place.()
        }
      )
      
      ValueFlows.Simulate.fake_proposed_intent!(geo_proposal, geo_intent)
      
      # Create economic resources and events with locations
      resource_with_location = ValueFlows.Simulate.fake_economic_resource!(
        user, 
        %{
          current_location: random_place.()
        }
      )
      
      to_resource_with_location = ValueFlows.Simulate.fake_economic_resource!(
        random_user.(), 
        %{
          current_location: random_place.()
        }
      )
      
      ValueFlows.Simulate.fake_economic_event!(
        user,
        %{
          to_resource_inventoried_as: to_resource_with_location.id,
          resource_inventoried_as: resource_with_location.id,
          action: Faker.Util.pick(["transfer", "move"]),
          at_location: random_place.()
        }
      )
    end
    
    # If quantify is available, add measurements to some intents and events
    if Bonfire.Common.Extend.extension_enabled?(Bonfire.Quantify.Simulate) and
       length(units || []) > 0 do
      
      unit = Faker.Util.pick(units)
      
      # Create intent with measurement
      measured_intent = ValueFlows.Simulate.fake_intent!(
        random_user.(),
        %{action_id: action_id},
        unit
      )
      
      proposal = ValueFlows.Simulate.fake_proposal!(user)
      ValueFlows.Simulate.fake_proposed_intent!(proposal, measured_intent)
      
      # Create economic resources and events with measurements
      resource_with_measure = ValueFlows.Simulate.fake_economic_resource!(user, %{}, unit)
      to_resource_with_measure = ValueFlows.Simulate.fake_economic_resource!(random_user.(), %{}, unit)
      
      ValueFlows.Simulate.fake_economic_event!(
        user,
        %{
          to_resource_inventoried_as: to_resource_with_measure.id,
          resource_inventoried_as: resource_with_measure.id,
          action: Faker.Util.pick(["transfer", "move"])
        },
        unit
      )
    end
  end
end

IO.puts("[seeds] Seed data creation complete!")