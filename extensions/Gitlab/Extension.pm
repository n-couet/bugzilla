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

use parent qw(Bugzilla::Extension);

use Bugzilla::Constants;
use Bugzilla::Error;
use Bugzilla::Group;
use Bugzilla::User;
use Bugzilla::User::Setting;
use Bugzilla::Util qw(diff_arrays html_quote remote_ip);
use Bugzilla::Status qw(is_open_state);
use Bugzilla::Install::Filesystem;
use Bugzilla::WebService::Constants;


our $VERSION = '1.0';

sub install_update_db {
    my $dbh = Bugzilla->dbh;
    $dbh->bz_add_column('components', 'icon',
                        {TYPE => 'VARCHAR(255)', NOTNULL => 1, DEFAULT => '"https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Gnome-applications-other.svg/96px-Gnome-applications-other.svg.png"'});
    $dbh->bz_add_column('components', 'gitlab_id',
                        {TYPE => 'BIGINT', NOTNULL => 1, DEFAULT => -1});
    $dbh->bz_add_column('profiles', 'avatar',
                            {TYPE => 'VARCHAR(255)', NOTNULL => 1, DEFAULT => '"https://www.causes.com/assets/avatar_placeholder-9a2f53db6270aa02b5ae2c5af1ffc72b.svg"'});
    $dbh->bz_add_column('profiles', 'gitlab_id',
                            {TYPE => 'BIGINT', NOTNULL => 1, DEFAULT => -1});
    $dbh->_bz_schema()->add_table('gitlab_config', {
        FIELDS => [
            id => {TYPE => 'BIGINT', NOTNULL => 1, DEFAULT => 1},
            url => {TYPE => 'varchar(255)'},
            token => {TYPE => 'varchar(255)'}
        ],
        INDEXES => [],
    });
    $dbh->bz_add_table('gitlab_config');
    my $sth = $dbh->prepare("INSERT INTO gitlab_config (url, token) VALUES (NULL, NULL);");
    $sth->execute;
}

sub object_columns {
    my ($self, $args) = @_;
    my ($class, $columns) = @$args{qw(class columns)};

    if ($class->isa('Bugzilla::Product')) {
        push(@$columns, 'icon');
        push(@$columns, 'gitlab_id');
    }

    if ($class->isa('Bugzilla::User')) {
        push(@$columns, 'avatar');
        push(@$columns, 'gitlab_id');
    }
}

sub bug_end_of_create {
    my ($self, $args) = @_;

    # This code doesn't actually *do* anything, it's just here to show you
    # how to use this hook.
    my $bug = $args->{'bug'};
    my $timestamp = $args->{'timestamp'};

    my $bug_id = $bug->id;
    # Uncomment this line to see a line in your webserver's error log whenever
    # you file a bug.
    # warn "Bug $bug_id has been filed!";
}

# This must be the last line of your extension.
__PACKAGE__->NAME;
