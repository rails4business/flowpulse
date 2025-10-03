# require "test_helper"

# class PostsControllerTest < ActionDispatch::IntegrationTest
#   setup do
#     @post = posts(:one)
#   end

#   test "should get index" do
#     get posts_url
#     assert_response :success
#   end

#   test "should get new" do
#     get new_post_url
#     assert_response :success
#   end

#   test "should create post" do
#     assert_difference("Post.count") do
#       post posts_url, params: { post: { body: @post.body, cover_url: @post.cover_url, description: @post.description, folder_path: @post.folder_path, position: @post.position, published_at: @post.published_at, service_key: @post.service_key, slug: @post.slug, state: @post.state, subdomain: @post.subdomain, tags: @post.tags, title: @post.title, user_id: @post.user_id, video_url: @post.video_url, visibility: @post.visibility } }
#     end

#     assert_redirected_to post_url(Post.last)
#   end

#   test "should show post" do
#     get post_url(@post)
#     assert_response :success
#   end

#   test "should get edit" do
#     get edit_post_url(@post)
#     assert_response :success
#   end

#   test "should update post" do
#     patch post_url(@post), params: { post: { body: @post.body, cover_url: @post.cover_url, description: @post.description, folder_path: @post.folder_path, position: @post.position, published_at: @post.published_at, service_key: @post.service_key, slug: @post.slug, state: @post.state, subdomain: @post.subdomain, tags: @post.tags, title: @post.title, user_id: @post.user_id, video_url: @post.video_url, visibility: @post.visibility } }
#     assert_redirected_to post_url(@post)
#   end

#   test "should destroy post" do
#     assert_difference("Post.count", -1) do
#       delete post_url(@post)
#     end

#     assert_redirected_to posts_url
#   end
# end
