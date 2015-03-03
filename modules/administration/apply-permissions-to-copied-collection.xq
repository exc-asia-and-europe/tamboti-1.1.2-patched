xquery version "3.0";

import module namespace config = "http://exist-db.org/mods/config" at "/db/apps/tamboti/modules/config.xqm";

declare function local:set-permissions($uri as xs:anyURI, $owner as xs:string, $group as xs:string, $mode as xs:string) {
    let $chown := sm:chown($uri, $owner)
    let $chgrp := sm:chgrp($uri, $group)
    let $chown := sm:chmod($uri, $mode)
    return 
        ()
};

let $collection-uri := xs:anyURI($config:mods-root || "/users/editor/importer-test-neu")
let $collection-owner := xmldb:get-owner($collection-uri)
let $collection-group := xmldb:get-group($collection-uri)

return
    (
        (: resources   :)
        for $res in xmldb:get-child-resources($collection-uri)
        return
            local:set-permissions(xs:anyURI($collection-uri || "/" || $res), $collection-owner, $collection-group, $config:resource-mode)
        ,
        (: VRA-images :)
            local:set-permissions(xs:anyURI($collection-uri || "/VRA_images"), $collection-owner, $collection-group, $config:collection-mode)
        ,
        (: resources in VRA_images  :)
        let $collection-uri := xs:anyURI($collection-uri || "/VRA_images")
        for $res in xmldb:get-child-resources($collection-uri)
        return
            local:set-permissions(xs:anyURI($collection-uri || "/" || $res), $collection-owner, $collection-group, $config:resource-mode)
    )
        
            

