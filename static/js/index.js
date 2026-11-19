window.HELP_IMPROVE_VIDEOJS = false;


$(document).ready(function() {
    // Mobile navbar burger: toggle the section menu
    $(".navbar-burger").click(function() {
        var expanded = $(this).toggleClass("is-active").hasClass("is-active");
        $(this).attr("aria-expanded", expanded);
        $("#" + $(this).data("target")).toggleClass("is-active");
    });

    // Close the mobile menu after choosing a section
    $(".site-nav .navbar-item").click(function() {
        $(".navbar-burger").removeClass("is-active").attr("aria-expanded", false);
        $("#sectionNav").removeClass("is-active");
    });

    // Highlight the nav link for the section currently in view
    var navLinks = $(".site-nav .nav-link");
    if ("IntersectionObserver" in window) {
        var observer = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    navLinks.removeClass("is-active");
                    navLinks.filter('[href="#' + entry.target.id + '"]').addClass("is-active");
                }
            });
        }, { rootMargin: "-40% 0px -55% 0px" });

        navLinks.each(function() {
            var section = document.querySelector($(this).attr("href"));
            if (section) observer.observe(section);
        });
    }

    var options = {
			slidesToScroll: 1,
			slidesToShow: 1,
			loop: true,
			infinite: true,
			autoplay: true,
			autoplaySpeed: 5000,
    }

		// Initialize all div with carousel class
    var carousels = bulmaCarousel.attach('.carousel', options);

    bulmaSlider.attach();

})
