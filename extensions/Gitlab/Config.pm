# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::Gitlab;

use 5.10.1;
use strict;
use warnings;

use constant NAME => 'Gitlab';

use constant REQUIRED_MODULES => [
];

use constant OPTIONAL_MODULES => [
];

# The map determines which verion of
# the Core API an extension's API modules
# were written to work with.
use constant API_VERSION_MAP => {
    '1_0' => '1_0',
    '2_0' => '1_0'
};

__PACKAGE__->NAME;
