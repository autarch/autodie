package Hints_pod_examples;
use strict;
use warnings;

use base qw(Exporter);

our @EXPORT_OK = qw(
	undef_scalar false_scalar zero_scalar empty_list default_list
	empty_or_false_list undef_n_error_list foo re_fail bar
	think_positive my_system bizarro_system	
);

use autodie::hints;

sub AUTODIE_HINTS {
    return {
        # Scalar failures always return undef:
        undef_scalar =>    {  scalar => undef  },

        # Scalar failures return any false value [default expectation]:
        false_scalar =>    {  scalar => sub { ! $_[0] }  },

        # Scalar failures always return zero explicitly:
        zero_scalar =>     {  scalar => '0'  },

        # List failures always return empty list:
        empty_list  =>     {  list => []  },

        # List failures return C<()> or C<(undef)> [default expectation]:
        default_list => {  list => sub { ! @_ || @_ == 1 && !defined $_[0] }  },

        # List failures return C<()> or a single false value:
        empty_or_false_list => {  list => sub { ! @_ || @_ == 1 && !$_[0] }  },

        # List failures return (undef, "some string")
        undef_n_error_list => {  list => sub { @_ == 2 && !defined $_[0] }  },
    };
}	

# Define some subs that all just return their arguments
sub undef_scalar { return @_ };
sub false_scalar { return @_ };
sub zero_scalar  { return @_ };
sub empty_list   { return @_ };
sub default_list { return @_ };
sub empty_or_false_list { return @_ };
sub undef_n_error_list { return @_ };


# Unsuccessful foo() returns 0 in all contexts...
autodie::hints->set_hints_for(
    \&foo,
    {
	scalar => 0,
	list   => [0],
    }
);

sub foo { return @_ };

# Unsuccessful re_fail() returns 'FAIL' or '_FAIL' in scalar context,
#                    returns (-1) in list context...
autodie::hints->set_hints_for(
    \&re_fail,
    {
	scalar => qr/^ _? FAIL $/xms,
	list   => [-1],
    }
);
sub re_fail { return @_ };

# Unsuccessful bar() returns 0 in all contexts...
autodie::hints->set_hints_for(
    \&bar,
    {
	fail => 0
    }
);
sub bar { return @_ };

# Unsuccessful think_positive() returns negative number on failure...
autodie::hints->set_hints_for(
    \&think_positive,
    {
	fail => sub { $_[0] < 0 }
    }
);
sub think_positive { return @_ };

# Unsuccessful my_system() returns non-zero on failure...
autodie::hints->set_hints_for(
    \&my_system,
    {
	fail => sub { $_[0] != 0 }
    }
);
sub my_system { return @_ };

# Unsuccessful bizarro_system() returns random value and sets $?...
autodie::hints->set_hints_for(
    \&bizarro_system,
    {
	fail => sub { defined $? }
    }
);
sub bizarro_system { ($?) = @_; return int rand (10);  };

1;
