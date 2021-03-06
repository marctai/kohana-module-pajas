<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Media extends Controller
{

	public function before() {
		// We need to load all theme modules
		foreach (scandir(MODPATH) as $modulePath)
		{
			if (substr($modulePath, 0, 5) == 'theme')
			{
				Kohana::modules(array($modulePath => MODPATH.$modulePath) + Kohana::modules());
			}
		}
	}

	public function action_css()
	{
		$path = $this->request->param('path');
		$file = Kohana::find_file('css', $path, 'css');
		if ($file)
		{
			$this->response->headers('Last-Modified', gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');
			$this->response->headers('Content-Type', 'text/css');
			echo file_get_contents($file);
		}
		else
		{
			throw new Http_Exception_404('File not found!');
		}
	}

	public function action_fonts()
	{
		$path                   = $this->request->param('path');
		$path_info              = pathinfo($path);
		$path_info['extension'] = strtolower($path_info['extension']);

		$file = Kohana::find_file('fonts', substr($path, 0, strlen($path) - (strlen($path_info['extension']) + 1)), $path_info['extension']);
		if ($file && in_array($path_info['extension'], array('eot', 'svg', 'ttf', 'woff')))
		{
			$this->response->headers('Last-Modified', gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

			if     ($path_info['extension'] == 'eot')  $this->response->headers('Content-Type', 'application/vnd.ms-fontobject');
			elseif ($path_info['extension'] == 'svg')  $this->response->headers('Content-Type', 'image/svg+xml');
			elseif ($path_info['extension'] == 'ttf')  $this->response->headers('Content-Type', 'font/ttf');
			elseif ($path_info['extension'] == 'woff') $this->response->headers('Content-Type', 'application/x-font-woff');

			echo file_get_contents($file);
		}
		else throw new Http_Exception_404('File not found!');
	}

	public function action_img()
	{
		$path      = $this->request->param('path');
		$path_info = pathinfo($path);

		$file = Kohana::find_file('img', substr($path, 0, strlen($path) - (strlen($path_info['extension']) + 1)), $path_info['extension']);
		if ($file)
		{
			$mime = File::mime_by_ext($path_info['extension']);
			if (substr($mime, 0, 5) == 'image')
			{
				$this->response->headers('Content-Type', 'content-type: '.$mime.'; encoding='.Kohana::$charset.';');

				// Getting headers sent by the client.
				$headers = apache_request_headers();

				$this->response->headers('Last-Modified', gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

				// Checking if the client is validating his cache and if it is current.
				if (isset($headers['If-Modified-Since']) && (strtotime($headers['If-Modified-Since']) == filemtime($file)))
				{
					// Client's cache IS current, so we just respond '304 Not Modified'.
					$this->response->status(304);
				}
				else
				{
					// Image not cached or cache outdated, we respond '200 OK' and output the image.
					$this->response->headers('Content-Length', strval(filesize($file)));
					$this->response->status(200);
					echo file_get_contents($file);
				}
			}
			else
			{
				// This is not an image, so we respond that it is not found
				throw new Http_Exception_404('File not found!');
			}
		}
		else
		{
			// File not found at all
			throw new Http_Exception_404('File not found!');
		}
	}

	public function action_js()
	{
		$path = $this->request->param('path');

		$file = Kohana::find_file('js', $path, 'js');
		if ($file)
		{
			$this->response->headers('Last-Modified', gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');
			$this->response->headers('Content-Type', 'application/javascript');
			echo file_get_contents($file);
		}
		else throw new Http_Exception_404('File not found!');
	}

	public function action_user_content_image()
	{
		$file = $this->request->param('file');

		// Find the file ending
		$file_parts  = explode('.', $file);
		$file_ending = end($file_parts);
		$filename    = $file;

		// Check if it needs resizing
		$cache_ending = '';

		list($original_width, $original_height) = getimagesize(Kohana::$config->load('user_content.dir').'/images/'.$filename);
		$wh_ratio = $original_width / $original_height;

		// Get params
		if (isset($_GET['width'])     && preg_match('/^\d+$/', $_GET['width'])) {}
		else $_GET['width']     = FALSE;

		if (isset($_GET['height'])    && preg_match('/^\d+$/', $_GET['height'])) {}
		else $_GET['height']    = FALSE;

		if (isset($_GET['maxwidth'])  && preg_match('/^\d+$/', $_GET['maxwidth'])) {}
		else $_GET['maxwidth']  = FALSE;

		if (isset($_GET['maxheight']) && preg_match('/^\d+$/', $_GET['maxheight'])) {}
		else $_GET['maxheight'] = FALSE;

		// Find out new dimensions
		if ($_GET['maxwidth'] && $_GET['maxheight'] && ! $_GET['height'] && ! $_GET['width'])
		{
			if (($_GET['maxwidth'] / $_GET['maxheight']) < $wh_ratio) $_GET['width']  = $_GET['maxwidth'];
			else                                                      $_GET['height'] = $_GET['maxheight'];
		}
		elseif ($_GET['maxwidth'] && ! $_GET['maxheight'] && ! $_GET['height'] && ! $_GET['width'])
			$_GET['width'] = $_GET['maxwidth'];
		elseif ( ! $_GET['maxwidth'] && $_GET['maxheight'] && ! $_GET['height'] && ! $_GET['width'])
			$_GET['height'] = $_GET['maxheight'];

		if ($_GET['height'] && ! $_GET['width']) $_GET['width']  = round($wh_ratio * $_GET['height']);
		if ($_GET['width'] && ! $_GET['height']) $_GET['height'] = round($_GET['width'] / $wh_ratio);

		if ( ! $_GET['width'] && ! $_GET['height'])
		{
			$_GET['height'] = $original_height;
			$_GET['width']  = $original_width;
		}

		if ($_GET['width']  != $original_width)  $cache_ending .= '_width_'.$_GET['width'];
		if ($_GET['height'] != $original_height) $cache_ending .= '_height_'.$_GET['height'];

		if ($cache_ending != '')
		{
			// Resizing needed

			// Make sure the cache dir exists
			$filename_parts = explode('/', $filename);
			unset($filename_parts[count($filename_parts) - 1]);

			$dir_to_create = Kohana::$cache_dir.'/user_content/images';
			foreach ($filename_parts as $new_dir) $dir_to_create .= '/'.$new_dir;

			$file = Kohana::$cache_dir.'/user_content/images/'.$filename.$cache_ending;
			if ( ! file_exists($file))
			{
				exec('mkdir -p '.$dir_to_create);
				exec('chmod -R a+w '.Kohana::$cache_dir.'/user_content/images'); // Make sure its writeable by all

				// Create a new cached resized file
				if ($file_ending == 'jpg' || $file_ending == 'jpeg')
				{
					$src = imagecreatefromjpeg(Kohana::$config->load('user_content.dir').'/images/'.$filename);
					$dst = imagecreatetruecolor($_GET['width'], $_GET['height']);
					imagecopyresampled($dst, $src, 0, 0, 0, 0, $_GET['width'], $_GET['height'], $original_width, $original_height);
					imagejpeg($dst, $file);
				}
				elseif ($file_ending == 'png')
				{
					$src = imagecreatefrompng(Kohana::$config->load('user_content.dir').'/images/'.$filename);
					$dst = imagecreatetruecolor($_GET['width'], $_GET['height']);
					imagecopyresampled($dst, $src, 0, 0, 0, 0, $_GET['width'], $_GET['height'], $original_width, $original_height);
					imagepng($dst, $file);
				}
				/* Somethings fucked up with the colors in GIFs...
				elseif ($file_ending == 'gif')
				{
					$src = imagecreatefromgif(Kohana::$config->load('user_content.dir').'/images/'.$filename);
					$dst = imagecreatetruecolor($calculated_width, $calculated_height);
					imagecopyresampled($dst, $src, 0, 0, 0, 0, $calculated_width, $calculated_height, $original_width, $original_height);
					imagegif($dst, $file);
				}
				*/
			}
		}
		else $file = Kohana::$config->load('user_content.dir').'/images/'.$file;

		if (file_exists($file))
		{
			$mime = File::mime_by_ext($file_ending);
			if (substr($mime, 0, 5) == 'image')
			{
				$this->response->headers('Content-Type', 'content-type: '.$mime.'; encoding='.Kohana::$charset.';');

				// Getting headers sent by the client.
				$headers = apache_request_headers();

				$this->response->headers('Last-Modified', gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

				// Checking if the client is validating his cache and if it is current.
				if (isset($headers['If-Modified-Since']) && (strtotime($headers['If-Modified-Since']) == filemtime($file)))
				{
					// Client's cache IS current, so we just respond '304 Not Modified'.
					$this->response->status(304);
				}
				else
				{
					// Image not cached or cache outdated, we respond '200 OK' and output the image.
					$this->response->headers('Content-Length', strval(filesize($file)));
					$this->response->status(200);
					echo file_get_contents($file);
				}
			}
			else
			{
				// This is not an image, so we respond that it is not found
				throw new Http_Exception_404('File not found!');
			}
		}
		else
		{
			// File not found at all
			throw new Http_Exception_404('File not found!');
		}
	}

	public function action_xsl()
	{
		$path = $this->request->param('path');

		$file = Kohana::find_file('xsl', $path, 'xsl');
		if ($file)
		{
			$this->response->headers('Content-type', 'text/xml; encoding='.Kohana::$charset.';');
			echo file_get_contents($file);
		}
		else
		{
			throw new Http_Exception_404('File not found!');
		}
	}

}
