package com.opcoach.genmodeladdon.core

import java.io.FileInputStream
import java.io.FileOutputStream
import org.apache.commons.io.IOUtils
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.eclipse.core.resources.IFolder

class EMFPatternExtractor implements Runnable {
	static final String EMF_CODEGEN_PLUGIN_SN = "com.opcoach.genmodeladdon.core"
	static final String EMF_CODEGEN_CLASSGEN_PATH = "/templates/model/Class.javajet"
	static final String TARGET_SOURCE_PATH = "templates"
	static final String TARGET_MODEL_PATH = "model"
	static final String TARGET_CLASS_TEMPLATE_FILE = "Class.javajet"

	static final String DEV_CLASS_PATTERN = "%DEV_CLASS_PATTERN%";
	static final String DEV_INTERFACE_PATTERN = "%DEV_INTERFACE_PATTERN%";

	final IProject targetProject

	final String devClassPattern
	final String devInterfacePattern

	new(IProject targetProject, String cp, String ip) {
		this.targetProject = targetProject
		this.devClassPattern = cp
		this.devInterfacePattern = ip
	}

	def private extractClassTemplateIncurrentPlugin() {
		val codegenBundle = Platform.getBundle(EMF_CODEGEN_PLUGIN_SN)
		val path = new Path(EMF_CODEGEN_CLASSGEN_PATH);
		// Return the jet class file from the plugin.
		FileLocator::openStream(codegenBundle, path, false)
	}

	override run() {
		val sourceJetFile = extractClassTemplateIncurrentPlugin()
		val templateFolder = createSourceDirectoryStructure()
		val file = templateFolder.getFile(TARGET_CLASS_TEMPLATE_FILE)

		// Fix issue #49 : always create the file (only 147 ko)
		// Read original file and replace patterns inside
		var content = IOUtils.toString(sourceJetFile, ResourcesPlugin.getEncoding());

		content = content.replaceFirst(DEV_CLASS_PATTERN, devClassPattern);
		content = content.replaceFirst(DEV_INTERFACE_PATTERN, devInterfacePattern);

		// Then write it in the project
		IOUtils.write(content, new FileOutputStream(file.location.toFile), ResourcesPlugin.getEncoding());

	}

	def createSourceDirectoryStructure() {
		if (targetProject instanceof IProject) {
			var tgtSourcePath = null as IPath
			val javaTargetProject = targetProject as IProject
			val sourcePath = javaTargetProject.getFolder(TARGET_SOURCE_PATH)
			createFolderIfNotExists(sourcePath)

			tgtSourcePath = sourcePath.fullPath
			if (tgtSourcePath != null) {
				val p = new Path(TARGET_SOURCE_PATH + "/" + TARGET_MODEL_PATH);
				val modelFolder = targetProject.getFolder(p)
				createFolderIfNotExists(modelFolder)
				return modelFolder
			}
			return null

		}
	}

	def createFolderIfNotExists(IFolder f) {

		if (!f.exists) {
			println("Create folder : " + f)

			try {
				f.create(true, true, new NullProgressMonitor())
			} catch (Exception e) {
				println("Unable to create the folder :  " + f);
				e.printStackTrace
			}
		} else {
			println("Checked this folder (it exists) : " + f)

		}

	}

}
