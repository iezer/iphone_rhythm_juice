
<?php

/**
 * Raw XML for iphone app.
 */

jimport( 'joomla.application.component.view');
JHTML::_('behavior.modal');

/**
 * HTML View class for the auto Component
 */
JHTML::_('behavior.formvalidation');

// no direct access
defined( '_JEXEC' ) or die( 'Restricted access' );
global $my;


jimport( 'joomla.application.component.view');
class LessonViewLesson extends JView
{
  function display() {

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>RJ User</key>
';

//$module=new LessonModelLesson;
//$isstudent=$module->ISStudent();

$model =& $this->getModel();
$loggedinUser = $model->get_loggedinUser();

$user =& JFactory::getUser();
if (!$user->guest) {
  //echo 'You are logged in as:<br />';
  //echo 'User name: ' . $user->username . '<br />';
  //echo 'Real name: ' . $user->name . '<br />';
  //echo 'User ID  : ' . $user->id . '<br />';

  echo'  <dict>
    <key>Authenticated</key>
    <true/>';

$redirectUrl = base64_encode('index.php?option=com_lesson&view=iphone&format=raw');
$redirectUrl = '&return='.$redirectUrl;
$joomlaLoginUrl = 'index.php?option=com_user&view=login&tmpl=component';
$finalUrl = $joomlaLoginUrl . $redirecturl;

echo "    
    <key>ReturnURL</key>
    <string>" . $redirectUrl . "</string>";

echo "    
    <key>Username</key>
    <string>$user->username</string>
    <key>First Name</key>
    <string>Isaac</string>
    <key>Last Name</key>
    <string>Ezer</string>
    <key>Premium</key>
    <true/>
    <key>Allowed Offline Lessons</key>
    <integer>1</integer>
    <key>Subscription End</key>
    <date>2012-03-31T15:00:00Z</date>
    <key>Lessons</key>";
echo '
    <array>';

$model =& $this->getModel();
$loggedinUser = $model->get_loggedinUser();

$query = $model->getMyLesson();
$db =& JFactory::getDBO();
$db->setQuery( $query );
$db->query();
$myLessons=$db->loadAssocList();
//var_dump($myLessons);

for ($i = 0; $i < count($myLessons); $i++) {
  $lesson = $myLessons[$i];
//  var_dump($lesson);
  echo "
      <dict>
	<key>Title</key>
        <string>" . $lesson['title'] . "</string>
        <key>Lesson ID</key>
        <integer>" . $lesson['id'] . "</integer>
        <key>Description</key>
        <string>" . $lesson['description'] . "</string>
";


//        <key>Title</key>
//        <string>Hand To Hand</string>
echo '        <key>Premium</key>
        <true/>
        <key>Instructors</key>
        <array>
          <string>Dax Hock</string>
          <string>Alice Mei</string>
        </array>
        <key>Chapters</key>
        <array>
';

$chapters = $model->get_lesson_chapter($lesson['id']);
for ($j = 0; $j < count($chapters); $j++) {
$chapter = $chapters[$j];
//var_dump($chapter);

echo "   
          <dict>
            <key>Name</key>
            <string>" . $chapter->chapter_name . "</string>
            <key>Chapter ID</key>
            <integer>" . $chapter->id . "</integer>
            <key>Filename</key>
            <string>" . $chapter->video . "</string>
            <key>Chapter Number</key>
            <integer>" . $chapter->chapterno . "</integer>
          </dict>";  
}
echo '
        </array>
      </dict>
';
}

echo '      <dict>
        <key>Title</key>
        <string>Texas Tommy</string>
        <key>Premium</key>
        <false/>
        <key>Instructors</key>
        <array>
          <string>Dax Hock</string>
          <string>Alice Mei</string>
        </array>
        <key>Chapter Paths</key>
        <array>
          <string>http://localhost/rj/dax-alice-toulouse.m4v</string>
          <string>http://localhost/rj/alhc-2008-dax-alice.m4v</string>
        </array>
        <key>Chapter Titles</key>
        <array>
          <string>Hand To Hand</string>
          <string>Slip Slop Shim Sham</string>
        </array>
      </dict>
    </array>
  </dict>
';
}
else
{
  echo'  <dict>
    <key>Authenticated</key>
    <false/>
  </dict>
';
}

echo '</dict>
</plist>';

//echo $my->id;
//echo '</root>';

}
}
?>
