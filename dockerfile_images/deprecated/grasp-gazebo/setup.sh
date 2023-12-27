export GAZEBO_MASTER_URI=${GAZEBO_MASTER_URI:-http://localhost:11345}
export GAZEBO_MODEL_DATABASE_URI=http://models.gazebosim.org
export GAZEBO_RESOURCE_PATH=/usr/share/gazebo-11:${GAZEBO_RESOURCE_PATH}
export GAZEBO_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/gazebo-11/plugins:${GAZEBO_PLUGIN_PATH}
export GAZEBO_MODEL_PATH=/usr/share/gazebo-11/models:${GAZEBO_MODEL_PATH}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins
export OGRE_RESOURCE_PATH=/usr/lib/x86_64-linux-gnu/OGRE-1.9.0

