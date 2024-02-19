// more menu:
// history
// preferences
// add-ons
// developer
// forget
// webide

// Show my windows and tabs from last time
user_pref("browser.startup.page", 3);

// URL bar clicking behavior
user_pref("browser.urlbar.clickSelectsAll", true);
user_pref("browser.urlbar.doubleClickSelectsAll", false);

// Enable search suggestions
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.urlbar.suggest.searches", true);

// Homepage
user_pref("browser.startup.homepage", "about:newtab");

// Newtab blank
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.enhanced", false);

// Do not show about:config warning
user_pref("general.warnOnAboutConfig", false);

// Default search engine
user_pref("browser.search.defaultenginename", "Google");
user_pref("browser.search.defaultenginename.US", "data:text/plain,browser.search.defaultenginename.US=Google");
user_pref("browser.search.selectedEngine", "Google");

// Completed Onboarding Tour
user_pref("browser.onboarding.tour.onboarding-tour-addons.completed", true);
user_pref("browser.onboarding.tour.onboarding-tour-customize.completed", true);
user_pref("browser.onboarding.tour.onboarding-tour-default-browser.completed", true);
user_pref("browser.onboarding.tour.onboarding-tour-private-browsing.completed", true);
user_pref("browser.onboarding.tour.onboarding-tour-search.completed", true);
user_pref("browser.onboarding.tour.onboarding-tour-sync.completed", true);
