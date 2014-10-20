xquery version "3.0";

import module namespace reports = "http://hra.uni-heidelberg.de/ns/tamboti/reports" at "../../reports/reports.xqm";
import module namespace config = "http://exist-db.org/mods/config" at "../../modules/config.xqm";

declare function local:move-collection-recursively($path) {
    let $data-collection-path := xs:anyURI(replace($path, "/resources/users", "/data/users"))
    return
        (
            for $collection in xmldb:get-child-collections(xmldb:encode($path))
            let $collection-path := xs:anyURI($path || "/" || $collection)
            let $permissions := sm:get-permissions($collection-path)
            let $owner := $permissions/*/@owner
            let $mode := $config:collection-mode
            let $copied-collection-path := xs:anyURI($data-collection-path || "/" || $collection)
            return
                (
                    <collection name="{$collection}" path="{$path}">
                        <owner>{$owner}</owner>
                        <mode>{$mode}</mode>
                        <data-collection-path>{$data-collection-path}</data-collection-path>
                    </collection>
                    ,
                    xmldb:create-collection($data-collection-path, $collection)
                    ,
                    sm:chgrp($copied-collection-path, $config:biblio-users-group)
                    ,
                    sm:chown($copied-collection-path, $owner)
                    ,
                    sm:chmod($copied-collection-path, $config:collection-mode)
                    ,
                    local:move-collection-recursively($collection-path)
                )
            ,
            for $resource in xmldb:get-child-resources(xmldb:encode($path))
            let $resource-path := xs:anyURI($path || "/" || $resource)
            let $permissions := sm:get-permissions($resource-path)
            let $owner := $permissions/*/@owner
            let $mode := $config:collection-mode
            let $copied-resource-path := xs:anyURI($data-collection-path || "/" || $resource)
            return
                (
                    <resource name="{$resource}" path="{$path}">
                        <owner>{$owner}</owner>
                        <mode>{$mode}</mode>
                        <data-collection-path>{$data-collection-path}</data-collection-path>                
                    </resource>
                    ,
                    xmldb:copy($path, $data-collection-path, $resource)
                    ,
                    sm:chgrp($copied-resource-path, $config:biblio-users-group)
                    ,
                    sm:chown($copied-resource-path, $owner)
                    ,
                    sm:chmod($copied-resource-path, $config:resource-mode)
                )
        )
};

<result>
    {
        local:move-collection-recursively("/resources/commons/Annotated Videos")
    }
</result>
