package Fibre::Fun;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Data::Dumper;

our $VERSION = '0.1';

my $global_regexp_fibre_input_to_db = '\A[A-Za-z0-9,_]+\Z';
my @global_hvikt_fibre_columns = qw/LOCATION TYPE CONNECTOR_FROM CONNECTOR_TO LENGTH AMOUNT UPDATED UPDATED_BY/;


get '/' => sub {
	my $column_order = \@global_hvikt_fibre_columns;
    template 'index', {
    	fibre_types_table 	=> 	get_fibre_types_from_db(),
    	column_order 		=>	$column_order 
    };
};

get '/add_new_fibre_type' => sub {
    if(defined(session('fibre_params_from_user'))){
    	my $fp = session('fibre_params_from_user');
    	info "get add_new_fibre_type";
    	info Dumper($fp);
    	template 'add_new_fibre_type', { hei => $fp };
    	   	
    }else{
    	template 'add_new_fibre_type';
    	
    }
    
};

post '/add_new_fibre_type' => sub {
	my $fp = params;
	session fibre_params_from_user => $fp;
	info "post add_new_fibre_type";
	info Dumper(session('fibre_params_from_user'));
	
	add_fibre_type_to_db($fp);
	    
    redirect '/add_new_fibre_type';
};

sub build_insert_query{
	my $fibre_params_from_user = shift;
	my $fibre_input_to_db;
	
	
	foreach my $fp (keys %{$fibre_params_from_user}){
		if($fp =~ /\Atext_fibre_([a-z_]+)\Z/){
			my $row_name = uc $1;
			
			info "build_insert_query() Checking value $fibre_params_from_user->{$fp} for param $fp against REGEXP: $global_regexp_fibre_input_to_db";
			
			if($fibre_params_from_user->{$fp} =~ /$global_regexp_fibre_input_to_db/ ){
				$fibre_input_to_db->{$row_name}{NEW_FIELD} = 1;	
				info "NEW PARAM: $fibre_params_from_user, $fp, $fibre_input_to_db, $row_name";
				$fibre_input_to_db = update_insert_query_hash($fibre_params_from_user, $fp, $fibre_input_to_db, $row_name);		
			}

			
			
		}elsif($fp =~ /\Aselect_fibre_([a-z_]+)\Z/){
			my $row_name = uc $1;
			unless( $fibre_input_to_db->{$row_name}{NEW_FIELD}){
				info "OLD PARAM: $fibre_params_from_user, $fp, $fibre_input_to_db, $row_name";
				$fibre_input_to_db = update_insert_query_hash($fibre_params_from_user, $fp, $fibre_input_to_db, $row_name);
				
			}			
			
		}
		
	}
	info "FIBRE_INPUT_TO_DB\n " . Dumper($fibre_input_to_db);
	return $fibre_input_to_db;
	
}

sub update_insert_query_hash {
	my $fibre_params_from_user 	= shift;
	my $fp 						= shift;
	my $fibre_input_to_db 		= shift;
	my $row_name				= shift;
		
	info "update_insert_query_hash() Checking value $fibre_params_from_user->{$fp} for param $fp against REGEXP: $global_regexp_fibre_input_to_db";
	    
	if($fibre_params_from_user->{$fp} =~ /$global_regexp_fibre_input_to_db/){
		info "update_insert_query_hash() Updating $row_name with $fibre_params_from_user->{$fp}";
		$fibre_input_to_db->{$row_name}{VALUE} = $fibre_params_from_user->{$fp};				
	}
	
	info "update_insert_query_hash() VALUE: " . $fibre_input_to_db->{$row_name}{VALUE};
	return $fibre_input_to_db;
}
sub add_fibre_type_to_db {
	my $fibre_params_from_user = shift;
	my $form_data_to_db = build_insert_query($fibre_params_from_user);
	
	# LOCATION TYPE CONNECTOR_FROM CONNECTOR_TO LENGTH AMOUNT UPDATED UPDATED_BY
	
	my @values;
	
	foreach my $column (@global_hvikt_fibre_columns){
		if(defined $form_data_to_db->{$column}{VALUE}){
			push @values, $form_data_to_db->{$column}{VALUE};
			info "add_fibre_type_to_db() $column has value " . $form_data_to_db->{$column}{VALUE} ;
		}else{
			if($column eq "AMOUNT"){
				push @values, "0";			
			}
			if($column eq "UPDATED"){
				my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                localtime(time);
				push @values, ($year += 1900)."-".($mon + 1)."-$mday $hour:$min";			
			}
			if($column eq "UPDATED_BY"){				
				push @values, $ENV{HTTP_HOST};
			}
		}
		
	}
	
	info "add_fibre_type_to_db() values ready for INSERT: \n\n @{values} \n\n";
	
	my $sth = database->prepare(
		'INSERT INTO HVIKT_FIBRE (LOCATION, TYPE, CONNECTOR_FROM, CONNECTOR_TO, LENGTH, AMOUNT, UPDATED, UPDATED_BY) values(?,?,?,?,?,?,?,?)'
	);
	
	if(defined $sth){
		$sth->execute(@values);
		info Dumper($sth->fetchrow_hashref);
	}
		
}

sub remove_fibre_type_in_db {}

sub get_fibre_types_from_db {
	use Cwd;
	my $dir = getcwd;
	my $hvikt_fibre_from_db_href;
	info "Current dir: $dir";	

	my $sth = database->prepare(
		'select * from HVIKT_FIBRE'
	);
	
	if(defined $sth){
		$sth->execute();
		$hvikt_fibre_from_db_href = $sth->fetchall_hashref('ID');
		info "get_fibre_types_from_db() ". Dumper($hvikt_fibre_from_db_href);
	}
	
	return $hvikt_fibre_from_db_href;
}

sub uniq_fibre_type_in_db {}



true;
