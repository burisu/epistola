
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
    $($(this).data("remove")).fadeOut('fast', function() {
	$(this).remove();
    });
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
    target.children('.fs-overlay').fadeOut('fast', function() {
	$(this).remove();
    });
});

$("form[data-collect]").live("submit", function (event) {
    // Duplicates 
    var form = $(this), collector = $("<div></div>");
    form.children('.data-collector').remove();
    collector.addClass("data-collector").css("display", "none");
    form.append(collector);
    $(form.data("collect")).each(function (index) {
	$.each($(this).serializeArray(), function (j, couple) {
	    var hf, name, start = new RegExp("^file\\[", "ig");
	    name = couple.name;
	    if (start.test(name)) {
		hf = $("<input type='hidden'></input>");
		name = name.replace(start, "files["+index+"][");
		hf.attr({name: name, value: couple.value});
		collector.append(hf);
	    }
	});
    });
    return true;
});