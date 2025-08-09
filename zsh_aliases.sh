# Common variables for blog commands
BLOG_DIR="$HOME/Dev/RProjects/blog"
BLOG_PLATFORM="linux/amd64"
BLOG_CONTAINER="blog-site"

# Build the Docker image for the blog
alias blog_build_image='DOCKER_BUILDKIT=1 docker build \
  --platform=$BLOG_PLATFORM \
  -t $BLOG_CONTAINER \
  -f "$BLOG_DIR/Dockerfile" \
  "$BLOG_DIR" || echo "Error: Failed to build Docker image"'

# Build the blog content
alias blog_build='docker run --rm -it \
    --platform=$BLOG_PLATFORM \
    -v "$BLOG_DIR":/site \
    -w /site \
    -e FULL_BUILD \
    $BLOG_CONTAINER Rscript /usr/local/bin/blog_build.R || echo "Error: Failed to build blog"'
  

# Start local preview server
alias blog_preview='docker run --rm -it \
  --platform=$BLOG_PLATFORM \
  -v "$BLOG_DIR":/site \
  -w /site \
  -p 4321:4321 \
  $BLOG_CONTAINER Rscript /usr/local/bin/blog_preview.R || echo "Error: Failed to start preview server"'

# Create a new blog post
alias blog_new_post='docker run --rm -it \
  --platform=$BLOG_PLATFORM \
  -v "$BLOG_DIR":/site \
  -w /site \
  $BLOG_CONTAINER Rscript /usr/local/bin/new_post.R || echo "Error: Failed to create new post"'

