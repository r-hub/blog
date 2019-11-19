 $(document).ready(function() {
    // Fix Hugo's auto-generated Table of Contents.
    //   Must be performed prior to initializing ScrollSpy.
    $('#TableOfContents > ul > li > ul').unwrap().unwrap();
    $('#TableOfContents').addClass('nav flex-column');
    $('#TableOfContents li').addClass('nav-item');
    $('#TableOfContents li a').addClass('nav-link');
});