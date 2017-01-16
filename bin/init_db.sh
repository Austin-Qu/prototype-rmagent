set -x
set -e

rake db:drop
rake db:create
rake db:migrate
rake sample:sample_data
rake db:seed
