
// Update DOM with new system
$(document).on("ajax:success", "*[data-update]", function (event, data, status, xhr) {
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

$(document).on("click", "a[data-remove]", function () {
    $($(this).data("remove")).fadeOut('fast', function() {
	$(this).remove();
    });
    return false;
});

$(document).on("ajax:before", "form[data-remote][data-disable]", function (event) {
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

$(document).on("ajax:complete", "form[data-remote][data-disable]", function (event, request, status) {
    var element = $(this), target;
    target = $('#' + element.data("disable"));
    // target.attr("disabled", "false");
    target.children('.fs-overlay').fadeOut('fast', function() {
	$(this).remove();
    });
});

$(document).on("submit", "form[data-collect]", function (event) {
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

$.displayExport = function() {
    var files = $('#files'), exporter = $('#export');
    if (exporter.is(":hidden") && files.children(":visible").size() > 0) {
	exporter.fadeIn('fast');
    } else if (exporter.is(":visible") && files.children(":visible").size() <= 0) {
	exporter.fadeOut('fast');
    }
}

window.setInterval($.displayExport, 200);
