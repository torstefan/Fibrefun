package Fibre::Fun;
use Dancer ':syntax';
use Data::Dumper;

our $VERSION = '0.1';




get '/' => sub {
    template 'index';
};

get '/add_new_fibre_type' => sub {
    if(defined(session('fibre_params'))){
    	my $fp = session('fibre_params');
    	info "get add_new_fibre_type";
    	info Dumper($fp);
    	template 'add_new_fibre_type', { hei => $fp };
    	   	
    }else{
    	template 'add_new_fibre_type';
    	
    }
    
};

post '/add_new_fibre_type' => sub {
	my $fp = params;
	session fibre_params => $fp;
	info "post add_new_fibre_type";
	info Dumper(session('fibre_params'));    
    redirect '/add_new_fibre_type';
};

true;
