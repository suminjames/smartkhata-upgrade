<?php
$tag = 'B';
$ac = 'test';
$dt = date('YmdHis');
$mob = '9779801110951';
$msg = 'this is test';
$msg = str_replace(' ', '%20', $msg);
$u = 'test';
$p = 'test';


function sendsms($tag, $ac, $dt, $mob, $msg, $u, $p){
    $result = file_get_contents('http://api.miracleinfo.com.np/sms/smssend.php?'.
        'tag='.$tag.
        '&ac='.$ac.
        '&dt='.$dt.
        '&mob='.$mob.
        '&msg='.$msg.
        '&u='.$u.
        '&p='.$p)
    ;
    echo $result;    
}

sendsms($tag, $ac, $dt, $mob, $msg, $u, $p);
?>