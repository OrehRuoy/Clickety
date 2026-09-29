#import <Foundation/Foundation.h>
#include "widget_bridge.h"

// Defined in WidgetReload.swift (app target, added by add_widget_target.rb).
extern "C" void clickety_widget_reload(void);

static NSUserDefaults *wb_defaults() {
	static NSUserDefaults *s_defaults = nil;
	if (s_defaults != nil) return s_defaults;
	id group = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ClicketyAppGroup"];
	if (![group isKindOfClass:[NSString class]] || [(NSString *)group length] == 0) {
		NSLog(@"[Clickety WidgetBridge] ClicketyAppGroup missing from Info.plist");
		return nil;
	}
	s_defaults = [[NSUserDefaults alloc] initWithSuiteName:(NSString *)group];
	return s_defaults;
}

bool wb_is_available() {
	return wb_defaults() != nil;
}

bool wb_write_snapshot(const char *json) {
	NSUserDefaults *d = wb_defaults();
	if (d == nil || json == nullptr) return false;
	NSString *s = [NSString stringWithUTF8String:json];
	if (s == nil) return false;
	[d setObject:s forKey:@"snapshot"];
	return true;
}

void wb_reload() {
	dispatch_async(dispatch_get_main_queue(), ^{
		clickety_widget_reload();
	});
}

std::string wb_take_pending() {
	NSUserDefaults *d = wb_defaults();
	if (d == nil) return "[]";
	NSString *s = [d stringForKey:@"pending"];
	[d removeObjectForKey:@"pending"];
	if (s == nil || s.length == 0) return "[]";
	return std::string([s UTF8String]);
}
