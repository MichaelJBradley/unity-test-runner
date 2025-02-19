#!/usr/bin/env bash

# Set the license file path
UNITY_PROJECT_PATH=$GITHUB_WORKSPACE/$PROJECT_PATH

# Set the artifacts path
if [ -z "$ARTIFACTS_PATH" ]; then
  ARTIFACTS_PATH=artifacts
fi
FULL_ARTIFACTS_PATH=$GITHUB_WORKSPACE/$ARTIFACTS_PATH

# Set the modes for testing
case $TEST_MODE in
  editmode)
    echo "Edit mode selected for testing."
    EDIT_MODE=true
    ;;
  playmode)
    echo "Play mode selected for testing."
    PLAY_MODE=true
    ;;
  *)
    echo "All modes selected for testing."
    EDIT_MODE=true
    PLAY_MODE=true
    ;;
esac

# The following tests are 2019 mode (requires Unity 2019.2.11f1 or later)
# Reference: https://docs.unity3d.com/2019.3/Documentation/Manual/CommandLineArguments.html

#
# Overall info
#

echo ""
echo "###########################"
echo "#    Artifacts folder     #"
echo "###########################"
echo ""
echo "Creating \"$FULL_ARTIFACTS_PATH\" if it does not exist."
mkdir -p $FULL_ARTIFACTS_PATH

echo ""
echo "###########################"
echo "#    Project directory    #"
echo "###########################"
echo ""
ls -alh $UNITY_PROJECT_PATH

#
# Testing in EditMode
#

if [ $EDIT_MODE = true ]; then
  echo ""
  echo "###########################"
  echo "#   Testing in EditMode   #"
  echo "###########################"
  echo ""
  xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
    /opt/Unity/Editor/Unity \
      -batchmode \
      -logfile /dev/stdout \
      -projectPath "$UNITY_PROJECT_PATH" \
      -runTests \
      -testPlatform editmode \
      -testResults "$FULL_ARTIFACTS_PATH/editmode-results.xml"

  # Catch exit code
  EDIT_MODE_EXIT_CODE=$?

  # Display results
  if [ $EDIT_MODE_EXIT_CODE -eq 0 ]; then
    echo "Run succeeded, no failures occurred";
  elif [ $EDIT_MODE_EXIT_CODE -eq 2 ]; then
    echo "Run succeeded, some tests failed";
  elif [ $EDIT_MODE_EXIT_CODE -eq 3 ]; then
    echo "Run failure (other failure)";
  else
    echo "Unexpected exit code $EDIT_MODE_EXIT_CODE";
  fi
fi

#
# Testing in PlayMode
#

if [ $PLAY_MODE = true ]; then
  echo ""
  echo "###########################"
  echo "#   Testing in PlayMode   #"
  echo "###########################"
  echo ""
  xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
    /opt/Unity/Editor/Unity \
      -batchmode \
      -logfile /dev/stdout \
      -projectPath "$UNITY_PROJECT_PATH" \
      -runTests \
      -testPlatform playmode \
      -testResults "$FULL_ARTIFACTS_PATH/playmode-results.xml"

  # Catch exit code
  PLAY_MODE_EXIT_CODE=$?

  # Display results
  if [ $PLAY_MODE_EXIT_CODE -eq 0 ]; then
    echo "Run succeeded, no failures occurred";
  elif [ $PLAY_MODE_EXIT_CODE -eq 2 ]; then
    echo "Run succeeded, some tests failed";
  elif [ $PLAY_MODE_EXIT_CODE -eq 3 ]; then
    echo "Run failure (other failure)";
  else
    echo "Unexpected exit code $PLAY_MODE_EXIT_CODE";
  fi
fi

#
# Results
#

echo ""
echo "###########################"
echo "#    Project directory    #"
echo "###########################"
echo ""
ls -alh $UNITY_PROJECT_PATH

if [ $EDIT_MODE = true ]; then
  echo ""
  echo "###########################"
  echo "#    Edit Mode Results    #"
  echo "###########################"
  echo ""
  cat "$FULL_ARTIFACTS_PATH/editmode-results.xml"
  cat "$FULL_ARTIFACTS_PATH/editmode-results.xml" | grep test-run | grep Passed
fi

if [ $PLAY_MODE = true ]; then
  echo ""
  echo "###########################"
  echo "#    Edit Mode Results    #"
  echo "###########################"
  echo ""
  cat "$FULL_ARTIFACTS_PATH/playmode-results.xml"
  cat "$FULL_ARTIFACTS_PATH/playmode-results.xml" | grep test-run | grep Passed
fi

#
# Output variables
#

# Set resulting name as output variable
echo ::set-output name=artifactsPath::$ARTIFACTS_PATH

#
# Exit
#

if [ $EDIT_MODE_EXIT_CODE -gt 0 ]; then
  exit $EDIT_MODE_EXIT_CODE
fi

if [ $PLAY_MODE_EXIT_CODE -gt 0 ]; then
  exit $PLAY_MODE_EXIT_CODE
fi
