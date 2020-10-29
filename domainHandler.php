<?php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use Monolog\Formatter\LineFormatter;
use Monolog\Formatter\JsonFormatter;
/**
 * @uses curl_init exec, allow_url_fopen
 * @author airan.talles@gmail.com
 * @package oneinstack/lnmp
 * Simple script to sync vhosts programatically
 */
require "vendor/autoload.php";

function jssx($data){
    return $data;
}

/**
 * Get remote content
 *
 * @param [type] $url
 * @return void
 */
function getRemoteContent($url){
    $url = str_replace("&amp;", "&", urldecode(trim($url)));
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_HEADER, 0);

    curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows; U; Windows NT 6.1; tr-TR) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27");
    curl_setopt($ch, CURLOPT_AUTOREFERER, true);
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
 
    curl_setopt($ch, CURLOPT_ENCODING, "utf-8");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_REFERER, $url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Connection: Keep-Alive',
        'Keep-Alive: 300'
    ));
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);    # required for https urls
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_MAXREDIRS, 1000);
    $content = curl_exec($ch);
    curl_close($ch);


    return $content;
}
/**
 * please rename env file after install
 */
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();


$cdir = __DIR__ . '/tmp/'.date('dmY');
$cfile = $cdir.'/'.md5(date('dmY')).'.json';
echo "Working Log: {$cfile} \n";
if(!file_exists($cdir)){
    mkdir($cdir);
    touch($cfile,time());
}
if(!file_exists($cfile)){
    touch($cfile,time());
}
// create a log channel
$log = new Logger('domainHandler');
    // finally, create a formatter
$formatter = new JsonFormatter();
$stream = new StreamHandler($cfile, Logger::DEBUG);
$stream->setFormatter($formatter);
$log->pushHandler($stream);

$lnmpInstallDir = $_ENV['INSTALL_DIR'];

/**
 * use the syncDomains arg 
 */
if($argv[1]=='syncDomains') {

  
    /**
     * get active domains on server using exec command
     * @uses exec()
     */
    exec('sh '.$lnmpInstallDir.'vhostHandler.sh --list',$activeDomainsData);
    /**
     * @var array $activeDomainsData
     * @var array $activeDomains 
     * activeDomains store active domains on vhost
     */
    $activeDomains=[];
    /**
     * if exists domains get
     */
    if(is_array($activeDomainsData) and !empty($activeDomainsData)){
        foreach($activeDomainsData as $activeDomain){
            /**
             * bypass tenant domain
             */
            if($activeDomain !== $_ENV['TENANT_DOMAIN']){
                $activeDomains[]=$activeDomain;            
            }
        }
    }
    $remoteHeader = get_headers($_ENV['DOMAINS_API'],1);
    /**
     * @var string $remoteDomains 
     */
    $remoteDomains = getRemoteContent($_ENV['DOMAINS_API']);
    /**
     * @var array $enabledDomains
     * store active domains on laravel multitenancy 
     */
    if(!(strpos($remoteHeader[0],'200'))){
        $log->emergency(jssx(['message'=>'WebServer Error','body'=>$remoteDomains]));

    }
    if((mb_strpos($remoteDomains,'cloudflare'))){
        $log->emergency(jssx(['message'=>'CloudFlare Error','body'=>$remoteDomains]));
        die('CloudFlare Error');
    }

    $enabledDomains=[];
    $enableDomainsData = explode("\n",$remoteDomains);
    if(is_array($enableDomainsData) and !empty($enableDomainsData)){
        foreach($enableDomainsData as $enabledDomain){
            if(strlen($enabledDomain) > 2){
                $enabledDomains[]=$enabledDomain;            
            }
        }
        
        foreach ($enabledDomains as $enabledDomain){
            /**
             * Check if domains is present in active vhosts before vhost -add
             */
            if(!(in_array($enabledDomain,$activeDomains))) {
                exec('sh '.$lnmpInstallDir.'vhostHandler.sh --add --domain '.$enabledDomain,$enableDomainData);
                /**
                 * @var string $enableDomainData
                 * Server vhost response
                 */ 
                $log->info(jssx(['action'=>'addDomain','domain'=>$enabledDomain,'body'=>$enableDomainData]));
            }else{
                $log->debug(jssx(['action'=>'bypassAdd','domain'=>$enabledDomain]));

            }
        }
    
    } else{
        $log->error(jssx(['message'=>'Domains Error','body'=>$remoteDomains]));
        die('Domains Error');
    }

    /**
     * Refresh ServerVhosts
     */
    exec('sh '.$lnmpInstallDir.'vhostHandler.sh --list',$activeDomainsData);
    $activeDomains=[];
    foreach($activeDomainsData as $activeDomain){
        /**
         * bypass tenant domain
         */
        if($activeDomain !== $_ENV['TENANT_DOMAIN']){
            $activeDomains[]=$activeDomain;            
        }

    }  
    foreach($activeDomains as $actD){
        if(!(in_array($actD,$enabledDomains))) {
            exec('sh '.$lnmpInstallDir.'vhostHandler.sh --del --domain '.$actD, $deleteDomainData);
            $log->info(jssx(['action'=>'deleteDomain','domain'=>$actD,'body'=>$deleteDomainData]));
        }else{
            $log->debug(jssx(['action'=>'bypassDel','domain'=>$actD]));
        }
    } 
} 