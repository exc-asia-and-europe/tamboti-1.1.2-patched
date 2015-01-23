function loadContent(contentId) {
    $('#nav .hlist > ul > li').removeClass('active');
    $('#' + contentId + '-menu-item').addClass('active');
    $('#content-placeholder').load(contentId + '.html #content-placeholder > *');
    return false;
}
