<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">

			<xsl:call-template name="tab">
				<xsl:with-param name="href"   select="'images'" />
				<xsl:with-param name="text"   select="'List images'" />
			</xsl:call-template>

			<xsl:call-template name="tab">
				<xsl:with-param name="href"   select="'images/add_image'" />
				<xsl:with-param name="action" select="'add_image'" />
				<xsl:with-param name="text"   select="'Add image'" />
			</xsl:call-template>

		</ul>
	</xsl:template>

	<xsl:template match="/">
		<xsl:if test="/root/meta/action = 'index'">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Images'" />
				<xsl:with-param name="h1" select="'List images'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/meta/action = 'add_image'">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Images'" />
				<xsl:with-param name="h1" select="'Add image'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/meta/action = 'edit_image'">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Images'" />
				<xsl:with-param name="h1" select="'Edit image'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- List images -->
	<xsl:template match="content[../meta/controller = 'images' and ../meta/action = 'index']">
		<table>
			<thead>
				<tr>
					<th class="medium_row"></th>
					<th>Name</th>
					<th class="large_row">Tags</th>
					<th class="medium_row">Dimensions</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="/root/content/images/image">
					<xsl:sort select="@name" />
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><a href="../{URL}"><img src="../{URL}?width=99" alt="{@name}" /></a></td>
						<td><xsl:value-of select="name" /></td>
						<td>
							<xsl:for-each select="*[
																			local-name() != 'width' and
																			local-name() != 'height' and
																			local-name() != 'URL' and
																			local-name() != 'name'
																		]">
								<xsl:sort select="local-name(current())" />

								<strong><xsl:value-of select="local-name(current())" /></strong>

								<xsl:if test=". != ''">
									<strong>: </strong>
									<xsl:value-of select="." />
								</xsl:if>

								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>

							</xsl:for-each>
						</td>
						<td><xsl:value-of select="width" />x<xsl:value-of select="height" /></td>
						<td>
							<xsl:text>[</xsl:text>
							<a>
							  <xsl:attribute name="href">
								  <xsl:text>images/edit_image/</xsl:text>
								  <xsl:value-of select="@name" />
							  </xsl:attribute>
							  <xsl:text>Edit</xsl:text>
							</a>
							<xsl:text>] [</xsl:text>
							<a>
							  <xsl:attribute name="href">
								  <xsl:text>images/rm_image/</xsl:text>
								  <xsl:value-of select="@name" />
							  </xsl:attribute>
							  <xsl:text>Delete</xsl:text>
							</a>
							<xsl:text>]</xsl:text>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- Add an image -->
	<xsl:template match="content[../meta/controller = 'images' and ../meta/action = 'add_image']">
		<form method="post" enctype="multipart/form-data">
			<label for="file">
				<xsl:text>File: </xsl:text>
				<input id="file" type="file" name="file" />
			</label>

			<h2>Tags</h2>
			<p>Tag name: Tag value (value is optional)</p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>

			<label><input type="submit" value="Upload" /></label>
		</form>
	</xsl:template>

	<!-- Edit an image -->
	<xsl:template match="content[../meta/controller = 'images' and ../meta/action = 'edit_image']">
		<a href="../{image/URL}" class="column"><img src="../{image/URL}?width=300" alt="{image/@name}" /></a>

		<form method="post" class="column">
			<xsl:attribute name="action">images/edit_image/<xsl:value-of select="image/@name" /></xsl:attribute>

			<h2>Image data</h2>

			<!-- Name -->
			<xsl:choose>
				<xsl:when test="not(errors/form_errors/name)">
					<xsl:call-template name="form_line">
						<xsl:with-param name="id"    select="'name'" />
						<xsl:with-param name="label" select="'Image name:'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="errors/form_errors/name = 'Content_Image::image_name_available'">
					<xsl:call-template name="form_line">
						<xsl:with-param name="id"    select="'name'" />
						<xsl:with-param name="label" select="'Image name:'" />
						<xsl:with-param name="error" select="'This image name is already taken'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="errors/form_errors/name = 'Valid::not_empty'">
					<xsl:call-template name="form_line">
						<xsl:with-param name="id"    select="'name'" />
						<xsl:with-param name="label" select="'Image name:'" />
						<xsl:with-param name="error" select="'Image name is required'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id"    select="'name'" />
						<xsl:with-param name="label" select="'Image name:'" />
						<xsl:with-param name="error" select="concat('Unknown error: ',errors/form_errors/name)" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:for-each select="image/tags/tag">
				<xsl:sort select="@name" />
				<xsl:sort select="." />
				<p class="custom_row"><input type="text" name="tag[]" value="{@name}" />: <input type="text" name="tag_value[]" value="{.}" /></p>
			</xsl:for-each>

			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>
			<p class="custom_row"><input type="text" name="tag[]" />: <input type="text" name="tag_value[]" /></p>

			<!-- Already stored data - ->
			<xsl:for-each select="image/field">
				<xsl:if test="@name != 'name' and @name != 'URL'">
					<xsl:call-template name="form_line">
						<xsl:with-param name="id"    select="concat(@name,'_',position())" />
						<!- -xsl:with-param name="name"  select="concat(@name),'[]'" /- ->
						<xsl:with-param name="label" select="@name" />
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>

			<!- - New custom fields - ->
			<xsl:for-each select="/root/content/users/custom_detail_field">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id"    select="concat('field_',.,'_',(position() + count(/root/content/user/field)))" />
					<xsl:with-param name="name"  select="concat('fieldid_',.,'[]')" />
					<xsl:with-param name="label" select="/root/content/users/field[@id = current()]" />
				</xsl:call-template>
			</xsl:for-each>

			<p>(To remove a field, just leave it blank)</p-->


			<xsl:if test="../meta/action = 'add_image'">
				<xsl:call-template name="form_button">
					<xsl:with-param name="value" select="'Add image'" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="../meta/action = 'edit_image'">
				<xsl:call-template name="form_button">
					<xsl:with-param name="value" select="'Save changes'" />
				</xsl:call-template>
			</xsl:if>
		</form>
	</xsl:template>

</xsl:stylesheet>
