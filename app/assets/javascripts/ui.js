
// Update DOM with new system
$("*[data-update]").live("ajax:success", function (event, data, status, xhr) {
    var element = $(this);
    var position = $.trim(element.data("update-at")).toLowerCase();
    if (position === "top") {
	$(element.data("update")).prepend(data);
    } else if (position === "bottom") {
	$(element.data("update")).append(data);
    } else if (position === "before") {
	$(element.data("update")).before(data);
    } else if (position === "after") {
	$(element.data("update")).after(data);
    } else if (position === "replace") {
	$(element.data("update")).replaceWith(data);
    } else {
	$(element.data("update")).html(data);
    }
    return false;
});

$("a[data-remove]").live("click", function () {
    $($(this).data("remove")).fadeOut();
    return false;
});

$("form[data-remote][data-disable]").live("ajax:before", function (event) {
    var element = $(this), target, overlay = $("<div></div>"), offset;
    target = $('#' + element.data("disable"));
    offset = target.offset();
    // target.attr("disabled", "true");
    overlay.addClass("fs-overlay").css("display", "none");
    overlay.css({'position': 'absolute', 'width': target.innerWidth()+'px', 'height': target.innerHeight()+'px', 'top':offset.top+'px', 'left':offset.left+'px'});
    target.disablingOverlay = overlay;
    target.append(overlay);
    overlay.fadeIn();
});


$("form[data-remote][data-disable]").live("ajax:complete", function (event) {
    var element = $(this), target;
    target = $('#' + element.data("disable"));
    // target.attr("disabled", "false");
    target.children('.fs-overlay').fadeOut();
    target.children('.fs-overlay').remove();
});

$("form[data-collect]").submit(function () {
    // Duplicates 
    var form = $(this), targets, collector = $("<div></div>");
    targets = $(form.data("collect"));
    form.children('.data-collector').remove();
    form.append(collector);
    overlay.addClass("data-collector").css("display", "none");
    targets.each(function (target) {
	target.serializeArray().each(function (couple) {
	    var hf = $("<input type='hidden'></input>");
	    hf.attr(couple);
	    alert(couple.name);
	    collector.append(hf);
	});
    });
    return false;
});