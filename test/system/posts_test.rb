require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "should create post" do
    visit posts_url
    click_on "New post"

    fill_in "Banner url", with: @post.banner_url
    fill_in "Content", with: @post.content
    fill_in "Cover url", with: @post.cover_url
    fill_in "Description", with: @post.description
    fill_in "Meta", with: @post.meta
    fill_in "Published at", with: @post.published_at
    fill_in "Slug", with: @post.slug
    fill_in "Status", with: @post.status
    fill_in "Taxbranch", with: @post.taxbranch_id
    fill_in "Thumb url", with: @post.thumb_url
    fill_in "Title", with: @post.title
    fill_in "User", with: @post.lead_id
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "should update Post" do
    visit post_url(@post)
    click_on "Edit this post", match: :first

    fill_in "Banner url", with: @post.banner_url
    fill_in "Content", with: @post.content
    fill_in "Cover url", with: @post.cover_url
    fill_in "Description", with: @post.description
    fill_in "Meta", with: @post.meta
    fill_in "Published at", with: @post.published_at.to_s
    fill_in "Slug", with: @post.slug
    fill_in "Status", with: @post.status
    fill_in "Taxbranch", with: @post.taxbranch_id
    fill_in "Thumb url", with: @post.thumb_url
    fill_in "Title", with: @post.title
    fill_in "User", with: @post.lead_id
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "should destroy Post" do
    visit post_url(@post)
    accept_confirm { click_on "Destroy this post", match: :first }

    assert_text "Post was successfully destroyed"
  end
end
